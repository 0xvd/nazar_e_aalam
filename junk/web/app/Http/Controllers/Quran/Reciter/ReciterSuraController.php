<?php

namespace App\Http\Controllers\Quran\Reciter;

use App\Concerns\FileHandler;
use App\Concerns\HandlesChunkedUploads;
use App\Http\Controllers\Controller;
use App\Http\Requests\Quran\Reciter\ReciterSuraRequest;
use App\Models\Quran\Reciter\Reciter;
use App\Models\Quran\Reciter\ReciterSura;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ReciterSuraController extends Controller
{
    use FileHandler, HandlesChunkedUploads;

    private const MAX_CHUNK_SIZE = 5 * 1024 * 1024; // 5 MB

    public function index(Reciter $reciter)
    {
        $search = request('search');
        return ReciterSura::query()
            ->where('reciter_id', $reciter->id)
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%');
                $query->orWhere('number', 'like', '%' . $search . '%');
                $query->orWhere('revealed_place', 'like', '%' . $search . '%');
            })
            ->orderBy('number', 'ASC')
            ->paginate(10);
    }


    public function uploadChunk(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
            'chunkNumber' => ['required', 'integer', 'min:1'],
            'totalChunks' => ['required', 'integer', 'min:1'],
            'fileName' => ['required', 'string'],
            'reciterName' => ['required', 'string'],
            'file' => ['required', 'file', 'max:' . (self::MAX_CHUNK_SIZE / 1024)],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);

        if ($validatedData['chunkNumber'] > $validatedData['totalChunks']) {
            return response()->json(['status' => false, 'message' => 'Invalid chunk number'], 422);
        }

        $manifest = $this->readManifest($uploadId);

        if ($manifest && (int)$manifest['totalChunks'] !== (int)$validatedData['totalChunks']) {
            return response()->json([
                'status' => false,
                'message' => 'Upload session mismatch, please cancel and restart this upload',
            ], 409);
        }

        if (!$manifest) {
            $manifest = [
                'fileName' => $validatedData['fileName'],
                'reciterName' => $validatedData['reciterName'],
                'totalChunks' => (int)$validatedData['totalChunks'],
                'receivedChunks' => [],
            ];
        }

        try {
            $tempDir = $this->chunkTempDir($uploadId);
            $request->file('file')->move($tempDir, "chunk_{$validatedData['chunkNumber']}");

            $manifest['receivedChunks'] = array_values(array_unique(array_merge(
                $manifest['receivedChunks'],
                [(int)$validatedData['chunkNumber']]
            )));
            $this->writeManifest($uploadId, $manifest);

            return response()->json([
                'status' => 'chunk_uploaded',
                'receivedChunks' => $manifest['receivedChunks'],
                'totalChunks' => $manifest['totalChunks'],
            ]);
        } catch (\Exception $e) {
            Log::error("Error while uploading chunk {$validatedData['chunkNumber']} for upload {$uploadId}: " . $e->getMessage());
            return response()->json(['status' => false, 'message' => 'Error while uploading chunk'], 500);
        }
    }

    public function uploadStatus(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
        ]);

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

    public function completeUpload(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
            'totalChunks' => ['required', 'integer', 'min:1'],
            'fileName' => ['required', 'string'],
            'reciterName' => ['required', 'string'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $tempDir = $this->chunkTempDir($uploadId);
        $manifest = $this->readManifest($uploadId);

        if (!$manifest) {
            return response()->json(['status' => false, 'message' => 'Upload session not found'], 404);
        }

        $totalChunks = (int)$validatedData['totalChunks'];
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

        $reciterName = $this->slugSegment($validatedData['reciterName']);
        $fileName = $this->slugSegment($validatedData['fileName']);

        try {
            $destinationDir = storage_path("app/public/quran/{$reciterName}");
            if (!file_exists($destinationDir)) {
                mkdir($destinationDir, 0755, true);
            }

            $finalFilePath = "{$destinationDir}/{$fileName}.mp3";
            $mergedStream = fopen($finalFilePath, 'w+');

            for ($i = 1; $i <= $totalChunks; $i++) {
                $chunkStream = fopen("{$tempDir}/chunk_{$i}", 'r');
                stream_copy_to_stream($chunkStream, $mergedStream);
                fclose($chunkStream);
            }

            fclose($mergedStream);

            $this->removeDirectory($tempDir);

            Log::info("Upload {$uploadId} merged and stored successfully: {$finalFilePath}");

            return response()->json([
                'status' => 'completed',
                'filePath' => "/storage/quran/{$reciterName}/{$fileName}.mp3",
            ]);
        } catch (\Exception $exception) {
            Log::error("Error merging chunks for upload {$uploadId}: " . $exception->getMessage());
            return response()->json([
                'status' => false,
                'message' => 'Error merging chunks',
            ], 500);
        }
    }

    public function cancelUpload(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $this->removeDirectory($this->chunkTempDir($uploadId));

        return response()->json(['status' => true]);
    }

    public function store(ReciterSuraRequest $request)
    {
        try {
            DB::beginTransaction();

            $checkIfAlreadyExist = ReciterSura::query()
                ->where('reciter_id', $request->reciter_id)
                ->where('number', $request->number)
                ->first();

            if ($checkIfAlreadyExist) {
                return response()->json([
                    'status' => false,
                    'message' => 'Already Exists',
                    'data' => []
                ], 500);
            }

            $reciter = Reciter::query()->find($request->reciter_id);

            $sura = new ReciterSura([
                'reciter_id' => $request->reciter_id,
                'name' => $request->name,
                'number' => $request->number,
                'duration' => $request->duration,
                'revealed_place' => $request->revealed_place,
            ]);

            $suraNameNumber = strtolower(str_replace(' ', '_', $request->name)) . '_' . $request->number;
            $reciterName = strtolower(str_replace(' ', '_', $reciter->name));

            if ($request->hasFile('audio_file')) {
                $sura->path = $this->storeAudio($request->file('audio_file'), "quran/reciter-audio-sura/{$reciterName}", $suraNameNumber);
            } else {
                $sura->path = $request->audio_file;
            }

            $sura->save();

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Sura added successfully',
                'data' => []
            ]);
        } catch (\Exception $exception) {
            DB::rollback();
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => []
            ], 500);
        }
    }


    public function show(ReciterSura $reciterSura)
    {
        return $reciterSura;
    }

    public function update(ReciterSuraRequest $request, ReciterSura $reciterSura)
    {
        if ($request->id != $reciterSura->id) {
            return response()->json([
                'status' => false,
                'message' => 'It\'s not possible to edit other records',
            ]);
        }

        $reciterSura->name = $request->name;
        $reciterSura->number = $request->number;
        $reciterSura->revealed_place = $request->revealed_place;
        $reciterSura->duration = $request->duration;

        $suraNameNumber = strtolower(str_replace(' ', '_', $request->name)) . '_' . $request->number;
        $reciterName = strtolower(str_replace(' ', '_', $reciterSura->reciter->name));

        if ($request->hasFile('audio_file')) {
            $reciterSura->path = $this->storeAudio($request->file('audio_file'), "quran/reciter-audio-sura/{$reciterName}", $suraNameNumber);
        } else {
            $reciterSura->path = $request->audio_file;
        }

        $reciterSura->save();

        return response()->json([
            'status' => true,
            'message' => 'Sura updated successfully',
            'data' => []
        ]);

    }

    public function destroy(ReciterSura $reciterSura)
    {
        $reciterSura->delete();

        return response()->json([
            'status' => true,
            'message' => 'Sura deleted successfully',
            'data' => [],
        ]);
    }
}
