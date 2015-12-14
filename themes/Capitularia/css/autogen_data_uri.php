<?php

class T3_Ext_Autogen_Data_Uris
{

    public function __construct () {
    }

    public function __destruct () {
    }


    private function encode_file_to_base64 ($path) {
        $raw = file_get_contents ($path);
        if ($raw == false) {
            return false;
        }
        return base64_encode ($raw);
    }

    public function generate_uris ($src, $out) {
        $in = file_get_contents ($src);
        $out = fopen ($out, 'w');
        foreach (preg_split ("/((\r?\n)|(\r\n?))/", $in) as $line) {
            if (preg_match ("/(.*)url\(\'(.*)\'\)(.*)/", $line, $matches) ==  1) {
                $res_path = dirname ($src) . '/' . $matches[2];
                $data = 'data:' . mime_content_type ($res_path) . ';base64,' . $this->encode_file_to_base64 ($res_path);
                fwrite ($out, $matches[1] . "url('" . $data . "')" . $matches[3] . "\n");
            } else {
                fwrite ($out, $line . "\n");
            }
        }
        fclose ($out);
        //echo $this->encode_file_to_base64($src);
    }
}

$obj = new T3_Ext_Autogen_Data_Uris ();
$obj->generate_uris ('bg_img.css', 'bg_data_uri.css');
