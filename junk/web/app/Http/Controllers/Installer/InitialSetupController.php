<?php

namespace App\Http\Controllers\Installer;

use App\Http\Controllers\Controller;
use App\Models\Quran\Chapter\Chapter;
use App\Models\Quran\Chapter\ChapterDetail;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

class InitialSetupController extends Controller
{

    /**
     * @throws Exception
     */
    public function finish()
    {
        $chapterCount = Chapter::query()->count();
        if ($chapterCount == 114)
            return redirect()->route('dashboard')->with('error', 'Sorry you are already imported Quran Surah in your system.');

        try {
            DB::beginTransaction();
            config()->set('database.connections.mysql.strict', false);
            define('STDIN', fopen("php://stdin", "r"));

            Artisan::call('optimize:clear');

            Artisan::call('clear-compiled');
            Artisan::call('view:clear');

            Artisan::call('config:clear');
            Artisan::call('cache:clear');

            Artisan::call('db:seed', [
                '--class' => 'Database\\Seeders\\DefaultSeeder',
                '--force' => true
            ]);

            config()->set('database.connections.mysql.strict', true);
            DB::commit();

            return redirect()->route('dashboard')->with('success', 'Successfully Quran Surah Imported !!');
        } catch (Exception $exception) {
            DB::rollBack();
            dd($exception);
            return redirect()->route('dashboard')->with('error', $exception->getMessage());
        }
    }

    public function finishTransliteration()
    {
        try {
            DB::beginTransaction();
            $json = file_get_contents(resource_path('json/en_transliteration.json')); // Load JSON from public folder
            $data = json_decode($json, true);

            if (!$data) {
                dd("JSON file could not be loaded or decoded.");
            }


            foreach ($data['quran']['en.transliteration'] as $item) {
                $chapter = Chapter::where(['id' => $item['surah']])->first();
                $chapterDetail = ChapterDetail::where([
                    'chapter_id' => $chapter->id,
                    'verse_number' => $item['ayah']
                ])->first();


                $chapterDetail->english_transliteration = $item['verse'];
                $chapterDetail->save();
            }

            DB::commit();

            return redirect()->route('dashboard')->with('success', 'Successfully Quran Transliteration Imported !!');
        } catch (Exception $exception) {
            DB::rollBack();
            return redirect()->route('dashboard')->with('error', $exception->getMessage());
        }
    }
}
