<?php

namespace App\Jobs\Sura;

use App\Models\Quran\Reciter\BulkSuraImport;
use App\Models\Quran\Reciter\ReciterSura;
use App\Support\Mp3Duration;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Extracts a previously-uploaded ZIP of Surah MP3s and imports each file for a
 * reciter. Files are streamed out of the archive one at a time so memory stays
 * flat regardless of archive size, and a single failing file never aborts the
 * run — it is logged and the importer moves on.
 */
class BulkSuraImportJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /** Give large archives room to breathe. */
    public int $timeout = 3600;

    public int $tries = 1;

    public function __construct(public int $importId)
    {
    }

    public function handle(): void
    {
        $import = BulkSuraImport::find($this->importId);

        if (!$import) {
            Log::warning("BulkSuraImportJob: import {$this->importId} not found");
            return;
        }

        $zipPath = $import->zip_path;

        if (!$zipPath || !file_exists($zipPath)) {
            $this->fail($import, 'Uploaded ZIP archive could not be found on the server.');
            return;
        }

        $zip = new \ZipArchive();
        if ($zip->open($zipPath) !== true) {
            $this->fail($import, 'The uploaded file is not a valid ZIP archive.');
            return;
        }

        $suraMap = config('quran_suras.suras', []);

        // Pass 1: figure out which entries are importable so total_files reflects
        // real work (ignoring folders, junk, and non-mp3 files up front).
        $import->update(['status' => 'extracting', 'message' => 'Scanning archive...']);

        $entries = [];
        for ($i = 0; $i < $zip->numFiles; $i++) {
            $name = $zip->getNameIndex($i);
            if ($name === false) {
                continue;
            }

            $base = basename($name);

            // Skip directories, hidden/system files (e.g. __MACOSX, .DS_Store).
            if ($base === '' || str_ends_with($name, '/') || str_starts_with($base, '.') || str_contains($name, '__MACOSX')) {
                continue;
            }

            if (strtolower(pathinfo($base, PATHINFO_EXTENSION)) !== 'mp3') {
                continue;
            }

            $entries[] = ['index' => $i, 'name' => $name, 'base' => $base];
        }

        $import->update([
            'status' => 'processing',
            'total_files' => count($entries),
            'message' => 'Importing audio...',
        ]);

        $destinationDir = storage_path("app/public/quran/{$import->reciter_id}");
        if (!file_exists($destinationDir)) {
            mkdir($destinationDir, 0755, true);
        }

        foreach ($entries as $entry) {
            $import->current_file = $entry['base'];

            $number = $this->suraNumberFromFilename($entry['base']);

            // Validate Surah number range.
            if ($number === null || !isset($suraMap[$number])) {
                $import->skipped_count++;
                $import->processed++;
                $import->pushError($entry['base'], 'Filename does not map to a valid Surah number (1-114).');
                $import->save();
                continue;
            }

            $existing = ReciterSura::query()
                ->where('reciter_id', $import->reciter_id)
                ->where('number', $number)
                ->first();

            // Duplicate handling: skip unless the user opted to replace.
            if ($existing && !$import->replace_existing) {
                $import->skipped_count++;
                $import->processed++;
                $import->pushError($entry['base'], "Surah {$number} already exists (replace disabled).");
                $import->save();
                continue;
            }

            try {
                $destinationFile = "{$destinationDir}/{$number}.mp3";
                $this->extractEntryTo($zip, $entry['name'], $destinationFile);

                $meta = $suraMap[$number];
                $path = "/storage/quran/{$import->reciter_id}/{$number}.mp3";
                $duration = Mp3Duration::fromFile($destinationFile);

                if ($existing) {
                    $existing->update([
                        'name' => $meta['name'],
                        'revealed_place' => $meta['revealed_place'],
                        'duration' => $duration,
                        'path' => $path,
                    ]);
                } else {
                    ReciterSura::create([
                        'reciter_id' => $import->reciter_id,
                        'name' => $meta['name'],
                        'number' => $number,
                        'duration' => $duration,
                        'revealed_place' => $meta['revealed_place'],
                        'path' => $path,
                    ]);
                }

                $import->success_count++;
            } catch (\Throwable $e) {
                $import->failed_count++;
                $import->pushError($entry['base'], 'Import error: ' . $e->getMessage());
                Log::error("BulkSuraImportJob: failed importing {$entry['base']} for reciter {$import->reciter_id}: " . $e->getMessage());
            }

            $import->processed++;
            $import->save();
        }

        $zip->close();

        // Cleanup the uploaded archive.
        @unlink($zipPath);

        $import->update([
            'status' => 'completed',
            'current_file' => null,
            'message' => 'Import completed',
        ]);
    }

    /**
     * Stream a single archive entry to disk without loading it fully in memory.
     */
    private function extractEntryTo(\ZipArchive $zip, string $entryName, string $destination): void
    {
        $in = $zip->getStream($entryName);
        if ($in === false) {
            throw new \RuntimeException('Unable to read file from archive.');
        }

        $out = fopen($destination, 'w');
        if ($out === false) {
            fclose($in);
            throw new \RuntimeException('Unable to write file to storage.');
        }

        stream_copy_to_stream($in, $out);
        fclose($in);
        fclose($out);
    }

    /**
     * Derive the Surah number from a filename such as "5.mp3" or "005.mp3".
     */
    private function suraNumberFromFilename(string $base): ?int
    {
        $stem = pathinfo($base, PATHINFO_FILENAME);

        if (!preg_match('/^0*(\d{1,3})$/', trim($stem), $m)) {
            return null;
        }

        $number = (int) $m[1];

        return ($number >= 1 && $number <= 114) ? $number : null;
    }

    private function fail(BulkSuraImport $import, string $message): void
    {
        $import->update(['status' => 'failed', 'message' => $message]);

        if ($import->zip_path && file_exists($import->zip_path)) {
            @unlink($import->zip_path);
        }
    }

    /**
     * Ensure a crashed job still surfaces as failed to the UI.
     */
    public function failed(\Throwable $exception): void
    {
        $import = BulkSuraImport::find($this->importId);
        if ($import && !in_array($import->status, ['completed', 'failed'])) {
            $import->update([
                'status' => 'failed',
                'message' => 'Import failed: ' . $exception->getMessage(),
            ]);
        }
    }
}
