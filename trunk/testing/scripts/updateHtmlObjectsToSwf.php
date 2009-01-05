<?php
	$htmlDir = "../htmlObjectHarness";
	$svgViewer = "../SvgViewer.swf";
	
	$fhDir = openDir($htmlDir);
	
	while ($file = readdir($fhDir)) {
	    
	    $file = $htmlDir . "/" . $file;
	    
	    if (preg_match('/\.htm[l]*$/si', $file)) {
		$fh = fopen($file, "r");
		$content = fread($fh, filesize($file));
		fclose($fh);
		
		if (preg_match('/<object.*?\/>/si', $content, $match)) {
		    if (stripos($match[0], 'classid="') === false) {
			if (!preg_match('/data="([^"]+)" width="([^"]+)" height="([^"]+)"/si', $match[0], $matches)) {
			    print "Error updateing file: $file\n";
			    break;
			}
			$svg = $matches[1];
			$width = $matches[2];
			$height = $matches[3];
			
			$newTag = '
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
            codebase="" id="mySVGViewerObj" width=' . $width . ' height=' . $height . '>
    <param name=movie value="' . $svgViewer . '">
    <param name="FlashVars" value="sourceType=url_svg&svgURL=' . $svg . '">
    <param name="wmode" value="transparent">
    <embed play=false name="mySVGViewerObj" 
	    src="' . $svgViewer . '" quality=high wmode="transparent"
	    width=' . $width . ' height=' . $height . ' type="application/x-shockwave-flash"
	    FlashVars="sourceType=url_svg&svgURL=' . $svg . '">
    </embed >
</object>';
			$content = str_replace($match[0], $newTag, $content);
			
			$fh = fopen($file, "w");
			fwrite($fh, $content);
			fclose($fh);
		    }		    
		}
		else {
		    echo "File: $file, No object?\n";
		}
		
	    
	    }
	    
	}
	closedir($fhDir);
?>
