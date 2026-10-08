<?php

namespace App\Concerns;

use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\Facades\Image;

trait FileHandler
{
    protected string $storage_prefix = 'public';

    /**
     * @param UploadedFile $file
     * @param string $folder
     * @return
     */
    public function storeFile(UploadedFile $file, string $folder = 'avatar'): string
    {
        $name = Str::random(40) . "." . $file->getClientOriginalExtension();
        $file->storeAs("{$this->storage_prefix}/{$folder}", $name);
        return Storage::url($folder . '/' . $name);
    }

    public function saveImage(UploadedFile $file, $subdirectory = 'logo', $height = 300): object
    {
        try {
            $file_path = $subdirectory . '/' . uniqid() . '.' . $file->getClientOriginalExtension();
            Storage::put($this->storage_prefix . '/' . $file_path, $this->makeImage($file, $height)->__toString(), 'public');
            return (object)["success" => true, "message" => "File has been uploaded successfully", "path" => $file_path];
        } catch (Exception $exception) {
            $file_name = uniqid() . '.' . $file->getClientOriginalExtension();
            $file->storeAs($this->storage_prefix . '/' . $subdirectory, $file_name);
            return (object)["success" => true, "message" => "File has been uploaded successfully", "path" => $subdirectory . '/' . $file_name];
        }
    }

    public function makeImage(UploadedFile $file, $height = 300): \Intervention\Image\Image
    {
        return Image::make($file)->resize(null, $height, function ($constraint) {
            $constraint->aspectRatio();
        })->save();
    }

    public function uploadImage(UploadedFile $uploadedFile = null, $folder = "logo", $height = 300): ?string
    {
        if (is_null($uploadedFile))
            return null;
        $file = $this->saveImage($uploadedFile, $folder, $height);
        if ($file->success)
            return Storage::url($file->path);
        return null;
    }

    public function isFile(string $path = null): bool
    {
        return Storage::exists("{$this->storage_prefix}/{$path}");
    }

    public function deleteImage(string $path = null)
    {
        return $this->deleteFile($path);
    }

    public function removeStorage($path): array|string
    {
        return str_replace('/storage', '', $path);
    }

    public function deleteFile(string $path = null)
    {
        try {
            $path = $this->removeStorage($path);
            if ($this->isFile($path))
                return Storage::delete("{$this->storage_prefix}/{$path}");
        }catch (Exception $exception){
            return $exception;
        }
    }

    public function deleteMultipleFile(array $paths): bool
    {
        foreach ($paths as $path) {
            $this->deleteFile($path);
        }

        return true;
    }

    public function filePath(string $path = null): ?string
    {
        $path = $this->removeStorage($path);
        if ($this->isFile($path))
            return Storage::url("{$this->storage_prefix}/{$path}");
        return null;
    }

    public function storeAudio(UploadedFile $file, string $folder = 'audio',$suraName)
    {
        // Optionally check if the file is an audio type
        if (!$this->isAudioFile($file)) {
            throw new Exception("The uploaded file is not a valid audio file.");
        }

        $name = $suraName . "." . $file->getClientOriginalExtension();
        $file->storeAs("{$this->storage_prefix}/{$folder}", $name);

        return Storage::url($folder . '/' . $name);
    }

    public function isAudioFile(UploadedFile $file): bool
    {
        $mimeType = $file->getMimeType();
        // Check for common audio MIME types
        return in_array($mimeType, ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4']);
    }
}
