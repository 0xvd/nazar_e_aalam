<?php

namespace App\Concerns;

use Illuminate\Http\Exceptions\HttpResponseException;

trait HandlesChunkedUploads
{
    protected function validateUploadId(?string $uploadId): string
    {
        if (!$uploadId || !preg_match('/^[a-f0-9]{16,64}$/', $uploadId)) {
            throw new HttpResponseException(response()->json([
                'status' => false,
                'message' => 'Invalid upload id',
            ], 422));
        }

        return $uploadId;
    }

    protected function chunkTempDir(string $uploadId): string
    {
        return storage_path("app/temp_uploads/{$uploadId}");
    }

    protected function readManifest(string $uploadId): ?array
    {
        $manifestPath = $this->chunkTempDir($uploadId) . '/manifest.json';

        if (!file_exists($manifestPath)) {
            return null;
        }

        $data = json_decode(file_get_contents($manifestPath), true);

        return is_array($data) ? $data : null;
    }

    protected function writeManifest(string $uploadId, array $data): void
    {
        $tempDir = $this->chunkTempDir($uploadId);

        if (!file_exists($tempDir)) {
            mkdir($tempDir, 0755, true);
        }

        file_put_contents($tempDir . '/manifest.json', json_encode($data));
    }

    protected function slugSegment(string $value): string
    {
        $value = strtolower(trim($value));
        $value = preg_replace('/[^a-z0-9_-]+/', '_', $value);
        $value = trim($value, '_');

        return $value !== '' ? $value : 'file';
    }

    protected function removeDirectory(string $directory): void
    {
        if (!is_dir($directory)) {
            return;
        }

        $entries = scandir($directory);

        foreach ($entries as $entry) {
            if ($entry === '.' || $entry === '..') {
                continue;
            }

            $path = $directory . DIRECTORY_SEPARATOR . $entry;

            if (is_dir($path)) {
                $this->removeDirectory($path);
            } else {
                unlink($path);
            }
        }

        rmdir($directory);
    }
}
