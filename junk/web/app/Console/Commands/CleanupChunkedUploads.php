<?php

namespace App\Console\Commands;

use App\Concerns\HandlesChunkedUploads;
use Illuminate\Console\Command;

class CleanupChunkedUploads extends Command
{
    use HandlesChunkedUploads;

    protected $signature = 'uploads:cleanup-chunks {--hours=24 : Remove upload sessions older than this many hours}';

    protected $description = 'Remove abandoned chunked upload temp directories';

    public function handle(): int
    {
        $baseDir = storage_path('app/temp_uploads');

        if (!is_dir($baseDir)) {
            $this->info('No temp uploads directory found, nothing to clean up.');
            return self::SUCCESS;
        }

        $maxAgeSeconds = (int)$this->option('hours') * 3600;
        $removed = 0;

        foreach (scandir($baseDir) as $entry) {
            if ($entry === '.' || $entry === '..') {
                continue;
            }

            $path = $baseDir . DIRECTORY_SEPARATOR . $entry;

            if (is_dir($path) && (time() - filemtime($path)) > $maxAgeSeconds) {
                $this->removeDirectory($path);
                $removed++;
            }
        }

        $this->info("Removed {$removed} abandoned upload session(s).");

        return self::SUCCESS;
    }
}
