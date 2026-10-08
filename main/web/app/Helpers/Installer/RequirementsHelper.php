<?php

namespace App\Helpers\Installer;

use App\Helpers\Installer\Concerns\PhpInfoHelper;

class RequirementsHelper
{
    use PhpInfoHelper;

    protected bool $status = false;

    public function checkPHPVersion(string $minPhpVersion): array
    {
        $currentPhpServerVersion = $this->currentPhpServerVersion();

        if (version_compare($currentPhpServerVersion['version'], $minPhpVersion) >= 0) {
            $this->status = true;
        }
        return [
            'current_version' => $currentPhpServerVersion['version'],
            'minimum_version' => $minPhpVersion,
            'status' => $this->status
        ];
    }

    public function checkMysqlVersion($minMysqlVersion): array
    {
        $phpInfo = $this->phpInfoArray();

        $pdoMysql = extension_loaded('mysqli') ?  mysqli_get_client_info() : $phpInfo['pdo_mysql']['client_api_version'];
        $currentMysqlVersion = $this->getVersion($pdoMysql);

        $checkVersion = floatval($currentMysqlVersion) >= floatval($minMysqlVersion);

        return [
            'current_version' => $currentMysqlVersion,
            'minimum_version' => $minMysqlVersion,
            'status' => $checkVersion
        ];
    }

    public function checkRequirement(array $requirements): array
    {
        $results = [];

        foreach ($requirements as $type => $requirement) {
            switch ($type) {
                // check php requirements
                case 'php':
                    foreach ($requirements[$type] as $requirement) {

                        $results['requirements'][$type][$requirement] = true;

                        if (!extension_loaded($requirement)) {
                            $results['requirements'][$type][$requirement] = false;

                            $results['errors'] = true;
                        }
                    }
                    break;
                // check apache requirements
                case 'apache':
                    foreach ($requirements[$type] as $requirement) {
                        // if function doesn't exist we can't check apache modules
                        if (function_exists('apache_get_modules')) {
                            $results['requirements'][$type][$requirement] = true;

                            if (!in_array($requirement, apache_get_modules())) {
                                $results['requirements'][$type][$requirement] = false;

                                $results['errors'] = true;
                            }
                        }
                    }
                    break;
            }
        }

        return $results;
    }

    protected function currentPhpServerVersion(): array
    {
        $currentFullVersion = PHP_VERSION;

        return [
            'version' => $currentFullVersion
        ];
    }


    protected function getVersion($item): string
    {
        preg_match('@[0-9]+\.[0-9]+\.[0-9]+@', $item, $version);
        return $version[0];
    }
}
