<?php

namespace Database\Seeders\Quran\Chapter;

use App\Models\Quran\Chapter\Chapter;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ChapterTranslationSeederAr extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $chapterTranslationsSp = array(
            array('id' => '1', 'chapter_id' => '1', 'translator_id' => '3', 'translate_name' => 'الفاتحة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '2', 'chapter_id' => '2', 'translator_id' => '3', 'translate_name' => 'البقرة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '3', 'chapter_id' => '3', 'translator_id' => '3', 'translate_name' => 'علي عمران', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '4', 'chapter_id' => '4', 'translator_id' => '3', 'translate_name' => 'النساء', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '5', 'chapter_id' => '5', 'translator_id' => '3', 'translate_name' => 'المائدة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '6', 'chapter_id' => '6', 'translator_id' => '3', 'translate_name' => 'الأنعام', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '7', 'chapter_id' => '7', 'translator_id' => '3', 'translate_name' => 'الأعراف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '8', 'chapter_id' => '8', 'translator_id' => '3', 'translate_name' => 'الأنفال', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '9', 'chapter_id' => '9', 'translator_id' => '3', 'translate_name' => 'التوبة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '10', 'chapter_id' => '10', 'translator_id' => '3', 'translate_name' => 'يونس', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '11', 'chapter_id' => '11', 'translator_id' => '3', 'translate_name' => 'هود', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '12', 'chapter_id' => '12', 'translator_id' => '3', 'translate_name' => 'يوسف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '13', 'chapter_id' => '13', 'translator_id' => '3', 'translate_name' => 'الرعد', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '14', 'chapter_id' => '14', 'translator_id' => '3', 'translate_name' => 'ابراهيم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '15', 'chapter_id' => '15', 'translator_id' => '3', 'translate_name' => 'الحجر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '16', 'chapter_id' => '16', 'translator_id' => '3', 'translate_name' => 'النحل', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '17', 'chapter_id' => '17', 'translator_id' => '3', 'translate_name' => 'الإسراء', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '18', 'chapter_id' => '18', 'translator_id' => '3', 'translate_name' => 'الكهف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '19', 'chapter_id' => '19', 'translator_id' => '3', 'translate_name' => 'مريم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '20', 'chapter_id' => '20', 'translator_id' => '3', 'translate_name' => 'طه', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '21', 'chapter_id' => '21', 'translator_id' => '3', 'translate_name' => 'الأنبياء', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '22', 'chapter_id' => '22', 'translator_id' => '3', 'translate_name' => 'الحاج', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '23', 'chapter_id' => '23', 'translator_id' => '3', 'translate_name' => 'المؤمنون', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '24', 'chapter_id' => '24', 'translator_id' => '3', 'translate_name' => 'النور', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '25', 'chapter_id' => '25', 'translator_id' => '3', 'translate_name' => 'الفرقان', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '26', 'chapter_id' => '26', 'translator_id' => '3', 'translate_name' => 'الشعراء', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '27', 'chapter_id' => '27', 'translator_id' => '3', 'translate_name' => 'النمل', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '28', 'chapter_id' => '28', 'translator_id' => '3', 'translate_name' => 'القصاص', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '29', 'chapter_id' => '29', 'translator_id' => '3', 'translate_name' => 'العنبوت', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '30', 'chapter_id' => '30', 'translator_id' => '3', 'translate_name' => 'الروم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '31', 'chapter_id' => '31', 'translator_id' => '3', 'translate_name' => 'لقمان', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '32', 'chapter_id' => '32', 'translator_id' => '3', 'translate_name' => 'السجدة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '33', 'chapter_id' => '33', 'translator_id' => '3', 'translate_name' => 'الأحزاب', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '34', 'chapter_id' => '34', 'translator_id' => '3', 'translate_name' => 'سابا', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '35', 'chapter_id' => '35', 'translator_id' => '3', 'translate_name' => 'فاطر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '36', 'chapter_id' => '36', 'translator_id' => '3', 'translate_name' => 'ياسين', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '37', 'chapter_id' => '37', 'translator_id' => '3', 'translate_name' => 'الصافات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '38', 'chapter_id' => '38', 'translator_id' => '3', 'translate_name' => 'حزين', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '39', 'chapter_id' => '39', 'translator_id' => '3', 'translate_name' => 'الزمر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '40', 'chapter_id' => '40', 'translator_id' => '3', 'translate_name' => 'غافير', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '41', 'chapter_id' => '41', 'translator_id' => '3', 'translate_name' => 'فسيلات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '42', 'chapter_id' => '42', 'translator_id' => '3', 'translate_name' => 'الشورى', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '43', 'chapter_id' => '43', 'translator_id' => '3', 'translate_name' => 'الزخرف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '44', 'chapter_id' => '44', 'translator_id' => '3', 'translate_name' => 'الدخان', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '45', 'chapter_id' => '45', 'translator_id' => '3', 'translate_name' => 'الجاثية', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '46', 'chapter_id' => '46', 'translator_id' => '3', 'translate_name' => 'الأحقاف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '47', 'chapter_id' => '47', 'translator_id' => '3', 'translate_name' => 'محمد', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '48', 'chapter_id' => '48', 'translator_id' => '3', 'translate_name' => 'الفتح', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '49', 'chapter_id' => '49', 'translator_id' => '3', 'translate_name' => 'الحجرات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '50', 'chapter_id' => '50', 'translator_id' => '3', 'translate_name' => 'قاف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '51', 'chapter_id' => '51', 'translator_id' => '3', 'translate_name' => 'الذاريات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '52', 'chapter_id' => '52', 'translator_id' => '3', 'translate_name' => 'الطور', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '53', 'chapter_id' => '53', 'translator_id' => '3', 'translate_name' => 'النجم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '54', 'chapter_id' => '54', 'translator_id' => '3', 'translate_name' => 'القمر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '55', 'chapter_id' => '55', 'translator_id' => '3', 'translate_name' => 'الرحمن', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '56', 'chapter_id' => '56', 'translator_id' => '3', 'translate_name' => 'الواقعة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '57', 'chapter_id' => '57', 'translator_id' => '3', 'translate_name' => 'الحديد', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '58', 'chapter_id' => '58', 'translator_id' => '3', 'translate_name' => 'المجادلة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '59', 'chapter_id' => '59', 'translator_id' => '3', 'translate_name' => 'الحشر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '60', 'chapter_id' => '60', 'translator_id' => '3', 'translate_name' => 'الممتحنة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '61', 'chapter_id' => '61', 'translator_id' => '3', 'translate_name' => 'الصف', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '62', 'chapter_id' => '62', 'translator_id' => '3', 'translate_name' => 'الجمعة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '63', 'chapter_id' => '63', 'translator_id' => '3', 'translate_name' => 'المنافقون', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '64', 'chapter_id' => '64', 'translator_id' => '3', 'translate_name' => 'التغابون', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '65', 'chapter_id' => '65', 'translator_id' => '3', 'translate_name' => 'الطلا ', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '66', 'chapter_id' => '66', 'translator_id' => '3', 'translate_name' => 'التحريم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '67', 'chapter_id' => '67', 'translator_id' => '3', 'translate_name' => 'الملك', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '68', 'chapter_id' => '68', 'translator_id' => '3', 'translate_name' => 'القلم', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '69', 'chapter_id' => '69', 'translator_id' => '3', 'translate_name' => 'الحاقة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '70', 'chapter_id' => '70', 'translator_id' => '3', 'translate_name' => 'المعارج', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '71', 'chapter_id' => '71', 'translator_id' => '3', 'translate_name' => 'نوح', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '72', 'chapter_id' => '72', 'translator_id' => '3', 'translate_name' => 'الجن', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '73', 'chapter_id' => '73', 'translator_id' => '3', 'translate_name' => 'المزمل', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '74', 'chapter_id' => '74', 'translator_id' => '3', 'translate_name' => 'المدثر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '75', 'chapter_id' => '75', 'translator_id' => '3', 'translate_name' => 'القيامة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '76', 'chapter_id' => '76', 'translator_id' => '3', 'translate_name' => 'الإنسان', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '77', 'chapter_id' => '77', 'translator_id' => '3', 'translate_name' => 'المرسلات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '78', 'chapter_id' => '78', 'translator_id' => '3', 'translate_name' => 'النبأ', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '79', 'chapter_id' => '79', 'translator_id' => '3', 'translate_name' => 'النازية', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '80', 'chapter_id' => '80', 'translator_id' => '3', 'translate_name' => '\'عباس', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '81', 'chapter_id' => '81', 'translator_id' => '3', 'translate_name' => 'التكوير', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '82', 'chapter_id' => '82', 'translator_id' => '3', 'translate_name' => 'الانفطار', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '83', 'chapter_id' => '83', 'translator_id' => '3', 'translate_name' => 'المطففين', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '84', 'chapter_id' => '84', 'translator_id' => '3', 'translate_name' => 'الانشقاق', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '85', 'chapter_id' => '85', 'translator_id' => '3', 'translate_name' => 'البروج', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '86', 'chapter_id' => '86', 'translator_id' => '3', 'translate_name' => 'الطارق', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '87', 'chapter_id' => '87', 'translator_id' => '3', 'translate_name' => 'العلا', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '88', 'chapter_id' => '88', 'translator_id' => '3', 'translate_name' => 'الغاشية', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '89', 'chapter_id' => '89', 'translator_id' => '3', 'translate_name' => 'الفجر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '90', 'chapter_id' => '90', 'translator_id' => '3', 'translate_name' => 'البلد', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '91', 'chapter_id' => '91', 'translator_id' => '3', 'translate_name' => 'الشمس', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '92', 'chapter_id' => '92', 'translator_id' => '3', 'translate_name' => 'الليل', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '93', 'chapter_id' => '93', 'translator_id' => '3', 'translate_name' => 'الضحى', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '94', 'chapter_id' => '94', 'translator_id' => '3', 'translate_name' => 'الشرح', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '95', 'chapter_id' => '95', 'translator_id' => '3', 'translate_name' => 'في التين', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '96', 'chapter_id' => '96', 'translator_id' => '3', 'translate_name' => 'العلق', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '97', 'chapter_id' => '97', 'translator_id' => '3', 'translate_name' => 'القدر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '98', 'chapter_id' => '98', 'translator_id' => '3', 'translate_name' => 'البينة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '99', 'chapter_id' => '99', 'translator_id' => '3', 'translate_name' => 'الزلزلة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '100', 'chapter_id' => '100', 'translator_id' => '3', 'translate_name' => 'العاديات', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '101', 'chapter_id' => '101', 'translator_id' => '3', 'translate_name' => 'القارعة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '102', 'chapter_id' => '102', 'translator_id' => '3', 'translate_name' => 'التكاثر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '103', 'chapter_id' => '103', 'translator_id' => '3', 'translate_name' => 'العصر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '104', 'chapter_id' => '104', 'translator_id' => '3', 'translate_name' => 'الحمازة', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '105', 'chapter_id' => '105', 'translator_id' => '3', 'translate_name' => 'الفيل', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '106', 'chapter_id' => '106', 'translator_id' => '3', 'translate_name' => 'قريش', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '107', 'chapter_id' => '107', 'translator_id' => '3', 'translate_name' => 'الماعون', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '108', 'chapter_id' => '108', 'translator_id' => '3', 'translate_name' => 'الكوثر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '109', 'chapter_id' => '109', 'translator_id' => '3', 'translate_name' => 'الكافرون', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '110', 'chapter_id' => '110', 'translator_id' => '3', 'translate_name' => 'النصر', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '111', 'chapter_id' => '111', 'translator_id' => '3', 'translate_name' => 'المسد', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '112', 'chapter_id' => '112', 'translator_id' => '3', 'translate_name' => 'الإخلاص', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '113', 'chapter_id' => '113', 'translator_id' => '3', 'translate_name' => 'الفلق', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33'),
            array('id' => '114', 'chapter_id' => '114', 'translator_id' => '3', 'translate_name' => 'الناس', 'created_at' => '2023-11-30 10:33:33', 'updated_at' => '2023-11-30 10:33:33')
        );

        $result = [];
        foreach ($chapterTranslationsSp as $key => $item) {
            $result[] = [
                'chapter_id' => $item['chapter_id'],
                'translator_id' => 4,
                'translate_name' => $item['translate_name'],
                'created_at' => $item['created_at'],
                'updated_at' => $item['updated_at']
            ];
        }

        DB::table('chapter_translations')->insert($result);


    }
}
