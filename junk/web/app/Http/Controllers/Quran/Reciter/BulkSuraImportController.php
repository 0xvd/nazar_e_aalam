<?php

namespace App\Http\Controllers\Quran\Reciter;

use App\Concerns\HandlesChunkedUploads;
use App\Http\Controllers\Controller;
use App\Jobs\Sura\BulkSuraImportJob;
use App\Models\Quran\Reciter\BulkSuraImport;
use App\Models\Quran\Reciter\Reciter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Handles bulk reciter-audio imports:
 *   1. The ZIP is uploaded to the server in chunks (reusing HandlesChunkedUploads),
 *      so arbitrarily large archives never hit a request timeout.
 *   2. Once merged, an import record is created and a queued job is dispatched to
 *      extract + import each Surah audio file in the background.
 *   3. The frontend polls progress() to render live status.
 */
class BulkSuraImportController extends Controller
{
    use HandlesChunkedUploads;

    private const MAX_CHUNK_SIZE = 5 * 1024 * 1024; // 5 MB

    /**
     * Lightweight reciter list for the selection dropdown.
     */
    public function reciters()
    {
        return Reciter::query()
            ->select('id', 'name')
            ->orderBy('position', 'ASC')
            ->orderBy('name', 'ASC')
            ->get();
    }

    /**
     * Receive one chunk of the ZIP archive.
     */
    public function uploadChunk(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
            'chunkNumber' => ['required', 'integer', 'min:1'],
            'totalChunks' => ['required', 'integer', 'min:1'],
            'fileName' => ['required', 'string'],
            'file' => ['required', 'file', 'max:' . (self::MAX_CHUNK_SIZE / 1024)],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);

        if ($validatedData['chunkNumber'] > $validatedData['totalChunks']) {
            return response()->json(['status' => false, 'message' => 'Invalid chunk number'], 422);
        }

        $manifest = $this->readManifest($uploadId);

        if ($manifest && (int) $manifest['totalChunks'] !== (int) $validatedData['totalChunks']) {
            return response()->json([
                'status' => false,
                'message' => 'Upload session mismatch, please cancel and restart this upload',
            ], 409);
        }

        if (!$manifest) {
            $manifest = [
                'fileName' => $validatedData['fileName'],
                'totalChunks' => (int) $validatedData['totalChunks'],
                'receivedChunks' => [],
            ];
        }

        try {
            $tempDir = $this->chunkTempDir($uploadId);
            $request->file('file')->move($tempDir, "chunk_{$validatedData['chunkNumber']}");

            $manifest['receivedChunks'] = array_values(array_unique(array_merge(
                $manifest['receivedChunks'],
                [(int) $validatedData['chunkNumber']]
            )));
            $this->writeManifest($uploadId, $manifest);

            return response()->json([
                'status' => 'chunk_uploaded',
                'receivedChunks' => $manifest['receivedChunks'],
                'totalChunks' => $manifest['totalChunks'],
            ]);
        } catch (\Exception $e) {
            Log::error("Bulk import: error uploading chunk {$validatedData['chunkNumber']} for {$uploadId}: " . $e->getMessage());
            return response()->json(['status' => false, 'message' => 'Error while uploading chunk'], 500);
        }
    }

    /**
     * Report which chunks the server already has (for resume support).
     */
    public function uploadStatus(Request $request)
    {
        $validatedData = $request->validate(['uploadId' => ['required', 'string']]);
        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $manifest = $this->readManifest($uploadId);

        if (!$manifest) {
            return response()->json(['exists' => false, 'receivedChunks' => []]);
        }

        return response()->json([
            'exists' => true,
            'receivedChunks' => $manifest['receivedChunks'],
            'totalChunks' => $manifest['totalChunks'],
            'fileName' => $manifest['fileName'],
        ]);
    }

    /**
     * Merge all chunks into the final ZIP, create the import record and queue the job.
     */
    public function completeUpload(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
            'totalChunks' => ['required', 'integer', 'min:1'],
            'fileName' => ['required', 'string'],
            'reciter_id' => ['required', 'exists:reciters,id'],
            'replace_existing' => ['nullable', 'boolean'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $tempDir = $this->chunkTempDir($uploadId);
        $manifest = $this->readManifest($uploadId);

        if (!$manifest) {
            return response()->json(['status' => false, 'message' => 'Upload session not found'], 404);
        }

        $totalChunks = (int) $validatedData['totalChunks'];
        $missingChunks = [];

        for ($i = 1; $i <= $totalChunks; $i++) {
            $chunkPath = "{$tempDir}/chunk_{$i}";
            if (!in_array($i, $manifest['receivedChunks']) || !file_exists($chunkPath) || filesize($chunkPath) === 0) {
                $missingChunks[] = $i;
            }
        }

        if (!empty($missingChunks)) {
            return response()->json([
                'status' => false,
                'message' => 'Upload incomplete, some chunks are missing',
                'missingChunks' => $missingChunks,
            ], 409);
        }

        try {
            $destinationDir = storage_path('app/bulk_sura_imports');
            if (!file_exists($destinationDir)) {
                mkdir($destinationDir, 0755, true);
            }

            $zipPath = "{$destinationDir}/{$uploadId}.zip";
            $mergedStream = fopen($zipPath, 'w+');

            for ($i = 1; $i <= $totalChunks; $i++) {
                $chunkStream = fopen("{$tempDir}/chunk_{$i}", 'r');
                stream_copy_to_stream($chunkStream, $mergedStream);
                fclose($chunkStream);
            }

            fclose($mergedStream);
            $this->removeDirectory($tempDir);

            // Reject anything that is not a readable ZIP before queueing work.
            $zip = new \ZipArchive();
            if ($zip->open($zipPath) !== true) {
                @unlink($zipPath);
                return response()->json([
                    'status' => false,
                    'message' => 'The uploaded file is not a valid ZIP archive',
                ], 422);
            }
            $zip->close();

            $import = BulkSuraImport::create([
                'reciter_id' => $validatedData['reciter_id'],
                'zip_path' => $zipPath,
                'original_name' => $validatedData['fileName'],
                'replace_existing' => (bool) ($validatedData['replace_existing'] ?? false),
                'status' => 'queued',
                'message' => 'Import queued',
            ]);

            BulkSuraImportJob::dispatch($import->id);

            return response()->json([
                'status' => 'queued',
                'import_id' => $import->id,
            ]);
        } catch (\Exception $exception) {
            Log::error("Bulk import: error merging chunks for {$uploadId}: " . $exception->getMessage());
            return response()->json(['status' => false, 'message' => 'Error merging chunks'], 500);
        }
    }

    /**
     * Cancel an in-progress chunk upload.
     */
    public function cancelUpload(Request $request)
    {
        $validatedData = $request->validate(['uploadId' => ['required', 'string']]);
        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $this->removeDirectory($this->chunkTempDir($uploadId));

        return response()->json(['status' => true]);
    }

    /**
     * Poll the current state of an import.
     */
    public function progress(BulkSuraImport $import)
    {
        return response()->json([
            'id' => $import->id,
            'status' => $import->status,
            'current_file' => $import->current_file,
            'total_files' => $import->total_files,
            'processed' => $import->processed,
            'success_count' => $import->success_count,
            'failed_count' => $import->failed_count,
            'skipped_count' => $import->skipped_count,
            'message' => $import->message,
            'error_log' => $import->error_log ?? [],
        ]);
    }
}
