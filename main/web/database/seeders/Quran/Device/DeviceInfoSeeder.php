<?php

namespace Database\Seeders\Quran\Device;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DeviceInfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $data = [
            ['id' => 1, 'ip_address' => '103.161.68.149', 'os' => 'Mac', 'country' => 'Saudi Arabia', 'state' => 'Dhaka', 'latitude' => '23.7731', 'longitude' => '90.3657', 'count' => 1, 'created_at' => '2024-02-07 13:09:03', 'updated_at' => '2024-02-07 13:09:03'],
            ['id' => 2, 'ip_address' => '103.161.68.149', 'os' => 'Windows', 'country' => 'Ireland', 'state' => 'Dhaka', 'latitude' => '23.7731', 'longitude' => '90.3657', 'count' => 3, 'created_at' => '2024-02-07 13:09:03', 'updated_at' => '2024-02-07 13:09:03'],
            ['id' => 3, 'ip_address' => '103.161.68.149', 'os' => 'Android', 'country' => 'England', 'state' => 'Dhaka', 'latitude' => '23.7731', 'longitude' => '90.3657', 'count' => 10, 'created_at' => '2024-02-07 13:09:03', 'updated_at' => '2024-02-07 13:09:03'],
            ['id' => 4, 'ip_address' => '103.161.68.149', 'os' => 'Linux', 'country' => 'Saudi Arabia', 'state' => 'Dhaka', 'latitude' => '23.7731', 'longitude' => '90.3657', 'count' => 5, 'created_at' => '2024-02-07 13:09:03', 'updated_at' => '2024-02-07 13:09:03'],
            ['id' => 5, 'ip_address' => '103.161.68.149', 'os' => 'Android', 'country' => 'Portugal', 'state' => 'Dhaka', 'latitude' => '23.7731', 'longitude' => '90.3657', 'count' => 1, 'created_at' => '2024-02-07 13:09:03', 'updated_at' => '2024-02-07 13:09:03'],
        ];
        if (env('IS_DEMO_VERSION')) {
            DB::table('device_infos')->insert($data);
        }
    }
}
