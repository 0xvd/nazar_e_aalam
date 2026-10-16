<?php

namespace App\Helpers\Installer;

class PermissionHelper
{
    protected array $results = [];

    public function __construct()
    {
        $this->results['permissions'] = [];

        $this->results['errors'] = null;
    }


    public function check(array $folders): array
    {
        foreach ($folders as $folder => $permission) {
            if (!($this->getPermission($folder) >= $permission)) {
                $this->addFileAndSetErrors($folder, $permission, false);
            } else {
                $this->addFile($folder, $permission, true);
            }
        }

        return $this->results;
    }


    public function updateFolderPermissionCheck(array $permissions = []): array
    {
        $permissions = count($permissions) ? $permissions: config('install.permissions');
        foreach ($permissions as $folder => $permission) {
            if (! ($this->getFolderPermission($folder) >= $permission)) {
                $this->addFileAndSetErrors($folder, $permission, false);
            } else {
                $this->addFile($folder, $permission, true);
            }
        }

        return $this->results;
    }



    private function getPermission($folder): string
    {
        return substr(sprintf('%o', fileperms(base_path($folder))), -4);
    }

    private function getFolderPermission($folder): bool
    {
        if (is_dir(base_path($folder))) {
            return $this->createTestFile($folder);
        }else {
            return $this->testFile($folder);
        }
    }

    public function createTestFile($folder): bool
    {
        try {
            $file = fopen(base_path($folder.'test.txt'), 'w');
            fwrite($file, "John Doe\n");
            fclose($file);
            $this->deleteTestFile(base_path($folder.'test.txt'));
            return true;
        } catch (\Exception $exception) {
            return false;
        }
    }

    public function testFile($file_path): bool
    {
        try {
            $fp = fopen(base_path($file_path), 'a');
            fwrite($fp, 'TEST=TEST');
            fclose($fp);
            file_put_contents(base_path($file_path), str_replace(
                'TEST=TEST', '', file_get_contents(base_path($file_path))
            ));
            return true;
        }catch (\Exception $exception) {
            return false;
        }
    }

    public function deleteTestFile($file_path): void
    {
        unlink($file_path);
    }


    private function addFile($folder, $permission, $isSet): void
    {
        $this->results['permissions'][] = [
            'folder' => $folder,
            'permission' => $permission,
            'isSet' => $isSet,
        ];
    }



    private function addFileAndSetErrors($folder, $permission, $isSet): void
    {
        $this->addFile($folder, $permission, $isSet);

        $this->results['errors'] = true;
    }
}
