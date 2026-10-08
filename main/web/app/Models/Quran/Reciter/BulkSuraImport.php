<?php

namespace App\Models\Quran\Reciter;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BulkSuraImport extends Model
{
    use HasFactory;

    protected $fillable = [
        'reciter_id',
        'zip_path',
        'original_name',
        'replace_existing',
        'status',
        'current_file',
        'total_files',
        'processed',
        'success_count',
        'failed_count',
        'skipped_count',
        'message',
        'error_log',
    ];

    protected $casts = [
        'replace_existing' => 'boolean',
        'error_log' => 'array',
    ];

    public function reciter(): BelongsTo
    {
        return $this->belongsTo(Reciter::class);
    }

    /**
     * Append a single error entry to the log without clobbering existing ones.
     */
    public function pushError(string $file, string $reason): void
    {
        $log = $this->error_log ?? [];
        $log[] = ['file' => $file, 'reason' => $reason];
        $this->error_log = $log;
    }
}
