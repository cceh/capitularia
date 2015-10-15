<?php
	class t3_ext_autogen_data_uris {
		
		function __construct() {
		}
		
		function __destruct() {
		}
		
		
		private function encode_file_to_base64($path) {
			$raw = file_get_contents($path);
			if($raw == FALSE){return FALSE;}
			return base64_encode($raw);
		}
		
		function generate_uris($src,$out) {
			$in = file_get_contents($src);
			$out = fopen($out,'w');
			foreach(preg_split("/((\r?\n)|(\r\n?))/",$in) as $line){
				if(preg_match("/(.*)url\(\'(.*)\'\)(.*)/",$line,$matches) == 1){
					$res_path = dirname($src).'/'.$matches[2];
					$data = "data:".mime_content_type($res_path).";base64,".$this->encode_file_to_base64($res_path);
					fwrite($out,$matches[1]."url('".$data."')".$matches[3].'
					');
				}else{
					fwrite($out,$line.'
					');
				}
			}
			fclose($out);
			//echo $this->encode_file_to_base64($src);
		}
	}
  
?>

<?php
	$obj = new t3_ext_autogen_data_uris();
	$obj->generate_uris('bg_img.css','bg_data_uri.css');
?>
