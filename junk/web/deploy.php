<?php

/*
 * ATTENTION
 * Before you executing this request, please keep in mind the following:
 * 1. There must be folder named "original" inside the public_html
 * 2. All files/folders will be removed except the "original" once you execute this
 * 3. All files/folders will be copied to public_html from original folder
 * 4. All files/folders will be re-structured to work with cPanel
 * 5. Finally the https://www.yourdomain.com/install-demo-data url will be called to install demo data.
 * */


//Check if valid request or not.
//Set the key DEPLOYMENT_KEY .env in deployHQ.
//Set the urls in according to DEPLOYMENT_KEY in deployHQ


$key = trim($_REQUEST["key"]);
if (!$key) {
    die("Invalid key");
}

if (!check_valid_env("DEPLOYMENT_KEY", $key)) {
    die("Invalid request");
}


//So now, the've verified the request. Go ahead!

set_time_limit(900); //set execution time = 5 minutes. Since it could take time.


//In cPanel, we have to re-structure some folder and files.

if (check_valid_env("RESTRUCTURE", "true")) {

    echo "- Start removing all existing files from cPanel root. Except the original folder \r\n";
    remove_all_except_original_recursive();

    echo "- Copy everything from the original folder to root \r\n";
    copy_origianl_to_root();

    echo "- Prepare the src folder \r\n";
    prepare_src_folder();

    echo "- Move all from public to root folder \r\n";
    move_all_from_public_to_root();

    echo "- Prepare public folder in src folder \r\n";
    prepare_public_folder_in_src();

    echo "- Change path in index \r\n";
    change_path_in_index();

    if (check_valid_env("PREPARE_RELEASE_FILES", "true")) {
        copy_root_release();
    }

}

if (check_valid_env("INSTALL_DEMO_DATA", "true")) {
    $actual_link = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]";


    $actual_link = str_replace(get_original_folder_name() . "/", "", $actual_link);
    echo "- Install demo data \r\n";
    file_get_contents($actual_link . "/install-demo-data");
}


function custom_copy($src, $dst)
{
    if (is_dir($src)) {
        $dir = opendir($src);

        // Make the destination directory if not exist
        if (!is_dir($dst)) {
            mkdir($dst, 0755, true);
        }

        // Loop through the files in source directory
        foreach (scandir($src) as $file) {
            if (($file != '.') && ($file != '..')) {
                if (is_dir($src . '/' . $file)) {
                    // Recursively calling custom copy function for sub directory
                    custom_copy($src . '/' . $file, $dst . '/' . $file);
                } else {
                    copy($src . '/' . $file, $dst . '/' . $file);
                }
            }
        }

        closedir($dir);

    } else if ($src) {
        copy($src, $dst);  //copy file
    }
}


function rmdir_recursive($dir)
{
    foreach (scandir($dir) as $file) {
        if ('.' === $file || '..' === $file) continue;
        if (is_dir("$dir/$file")) rmdir_recursive("$dir/$file");
        else unlink("$dir/$file");
    }
    rmdir($dir);
}


function prepare_src_folder()
{
    $src_folder = array(
        "app", "lang", "bootstrap", "config", "database", "resources", "routes", "storage", "vendor",
        ".env", "artisan", "composer.json", "composer.lock", "package.json", "readme.md", "server.php"
    );


    foreach ($src_folder as $src) {
        $source = get_absolute_path($src);

        $dst = str_replace($src, "src/" . $src, $source);

        if (is_dir($source)) {
            custom_copy($source, $dst);
            rmdir_recursive($source); //remove directory
        } else if (file_exists($source)) {
            copy($source, $dst);
            unlink("$source");
        }

    }
}

function move_all_from_public_to_root()
{
    $source = get_absolute_path("public");
    $dst = str_replace("public_html", "root_html", $source); //backup public_html
    $dst = str_replace("public", "", $dst);
    $dst = str_replace("root_html", "public_html", $dst); //put back public_html

    if (is_dir($source)) {
        custom_copy($source, $dst);
        rmdir_recursive($source); //remove directory
    }
}

function prepare_public_folder_in_src()
{
    $public_dst = get_absolute_path("src");
    $public_dst = $public_dst . "/public";

    mkdir("$public_dst", 0755, true);
    mkdir("$public_dst/build", 0755, true);

    $src_folder = array(
        "/build/manifest.json"
    );

    foreach ($src_folder as $src) {

        $src_copy = $src;
        $dst = $public_dst . "/" . $src_copy;

        $source = get_absolute_path($src);

        if (is_dir($source)) {
            custom_copy($source, $dst);
            rmdir_recursive($source); //remove directory
        } else if (file_exists($source)) {
            copy($source, $dst);
            unlink("$source");
        }
    }

}

function change_path_in_index()
{
    $index = file_get_contents(get_absolute_path("index.php"));
    $index = str_replace("/../vendor/autoload.php", "/src/vendor/autoload.php", $index);

    $index = str_replace("/../bootstrap/app.php", "/src/bootstrap/app.php", $index);

    file_put_contents(get_absolute_path("index.php"), $index);
}


function check_valid_env($key, $value)
{
    $env_path = get_absolute_path("src") . "/.env";

    if (!file_exists($env_path)) {
        $env_path = get_absolute_path(".env", true); // try original folder
    }

    $env_content = @file_get_contents($env_path);

    if (!$env_content) return false;

    return strpos($env_content, "$key=$value") !== false;
}

function get_absolute_path($file_path = "", $show_original_folder = false)
{
    $root = dirname(__FILE__);

    if (!$show_original_folder) {
        $root = str_replace("/" . get_original_folder_name(), "", $root);
    }

    if ($file_path) return $root . "/" . $file_path;
    else return $root;
}


function copy_origianl_to_root()
{
    $source = get_absolute_path("", true);

    $dst = str_replace(get_original_folder_name(), "", $source);

    if (is_dir($source)) {
        custom_copy($source, $dst);
    }
}

function copy_root_release()
{

    $release_folder = "marketplace_version";
    $doc_folder = "documentation";
    $dont_copy = array($release_folder,
        get_original_folder_name(),
        $doc_folder,
        "template",
        "error_log",
        ".DS_Store",
        "deploy.php",
        ".github",
        ".gitattributes",
        ".gitignore",
        "FETCH_HEAD"
    );

    $src = get_absolute_path("", true);
    $src = str_replace(get_original_folder_name(), "", $src);

    $dst = $src . "/" . $release_folder . "/upload";

    mkdir("$dst", 0755, true);

    // Loop through the files in source directory
    foreach (scandir($src) as $file) {

        if (array_search($file, $dont_copy) === false && ($file != '.') && ($file != '..')) {

            if (is_dir($src . '/' . $file)) {
                // Recursively calling custom copy function for sub directory
                custom_copy($src . '/' . $file, $dst . '/' . $file);
            } else {
                copy($src . '/' . $file, $dst . '/' . $file);
            }
        } else if ($file == $doc_folder && is_dir($src . '/' . $file)) {
            custom_copy($src . '/' . $file, $src . "/" . $release_folder . '/' . $file);
        }
    }

}

function get_original_folder_name(): string
{
    return "original";
}

function remove_all_except_original_recursive(): void
{
    $dir = get_absolute_path();

    foreach (scandir($dir) as $file) {
        if ('.' === $file || '..' === $file) continue;

        if (is_dir("$dir/$file")) {
            if ($file == get_original_folder_name()) {
                //don't remove
            } else {
                rmdir_recursive("$dir/$file"); //remove directory
            }
        } else {
            unlink("$dir/$file"); //remove file
        }

    }

}
