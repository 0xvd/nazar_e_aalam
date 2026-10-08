<?php

namespace App\Jobs\Sura;

use App\Concerns\FileHandler;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SuraUploadJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels, FileHandler;

    protected $file;
    protected $path;
    protected $fileName;

    public function __construct($file, $path, $fileName)
    {
        $this->file = $file;
        $this->path = $path;
        $this->fileName = $fileName;
    }

    public function handle()
    {
        try {
            // Use the storeAudio function from the trait
            $path = $this->storeAudio($this->file, $this->folder, $this->suraName);
            // You can log the path or store it in the database
        } catch (\Exception $e) {
            // Handle any exceptions during upload
            logger()->error("File upload failed: " . $e->getMessage());
        }
    }
}
