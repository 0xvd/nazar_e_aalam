<?php

namespace App\Services\Installer;

use App\Exceptions\GeneralException;
use App\Services\BaseService;
use GuzzleHttp\Exception\ClientException;

class PurchaseCodeValidatorService extends BaseService
{
    protected RequestSenderService $request;

    public function __construct(RequestSenderService $request)
    {
        $this->request = $request;
    }

    /**
     * @throws GeneralException
     */
    public function validate($code)
    {

        try {
            //CurlHttp request
            $checkCurl = $this->curlPurchaseCodeValidation($code);

            if (optional($checkCurl)->data === "Verified") {
                return $checkCurl;
            }

            //GuzzleHttp request
            return $this->request->get(
                $this->url($code)
            );
        } catch (ClientException $exception) {
            throw new GeneralException($exception->getMessage());
        }
    }

    private function curlPurchaseCodeValidation($code)
    {
        $code = trim($code);
        $type = 'verification';
        $domain_name = request()->getHost();
        $config = config('theme');
        $head = $this->getHead($config);

        $attach = isset($config['use_update_route']) ? '/' . $config['use_update_route'] : null;

        $url = "{$config['marketplace_url']}{$attach}/{$type}/{$config['app_id']}?domain_name={$domain_name}&purchase_key={$code}&app_version={$config['app_version']}";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $head);

        return json_decode(curl_exec($ch));
    }

    private function getHead($config): array
    {
        return array('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Charset' => 'ISO-8859-2,utf-8;q=0.7,*;q=0.3',
            'Accept-Encoding' => 'gzip,deflate,sdch',
            'Accept-Language' => 'ro-RO,ro;q=0.8,en-US;q=0.6,en;q=0.4',
            'Cache-Control' => 'max-age=0',
            'Connection' => 'keep-alive',
            'Cookie' => 'datr=hroHTi2NZk2KleOaswb03Q_Q; lu=gg9lJcPeInHt6hnut7bviqQg; locale=en_US; e=n; L=2; c_user=100000596376783; sct=1309129360; xs=2%3Ad05dd80e364608525dd664ad73f6483f; act=1309410851554%2F5; presence=EM309410852L4N0_5dEp_5f1B00596376783F1X309410852168Y0Z11G309410768PCC',
            'Host' => $config['update_url'],
            'User-Agent' => $_SERVER['HTTP_USER_AGENT']);
    }

    public function url($code = '', $type = 'verification'): string
    {
        $code = trim($code);
        $domain_name = request()->getHost();
        $config = config('theme29');
        return "{$config['marketplace_url']}/{$type}/{$config['app_id']}?domain_name={$domain_name}&purchase_key={$code}&app_version={$config['app_version']}";
    }
}
