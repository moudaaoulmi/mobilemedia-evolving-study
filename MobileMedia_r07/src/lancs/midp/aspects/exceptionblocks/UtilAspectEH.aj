package lancs.midp.aspects.exceptionblocks;

import java.io.IOException;
import java.io.InputStream;

import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageFormatException;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.util.MediaUtil;

public aspect UtilAspectEH {
	
	//Method ImageUtil.readImageAsByteArray 1- block - Scenario 3
	pointcut readMediaAsByteArray(String mediaFile): 
		 (call(public void Class.getResourceAsStream(String))&&(args(mediaFile)))&& withincode(public byte[] MediaUtil.readMediaAsByteArray(String)) ;
	
	after(String mediaFile) throwing(Exception e) throws  ImagePathNotValidException: readMediaAsByteArray(mediaFile){
		throw new ImagePathNotValidException(
				"Path not valid for this image:"+mediaFile);
	}
	
	//Method ImageUtil.readImageAsByteArray 2- block - Scenario 3
	pointcut readInternalMediaAsByteArray(String mediaFile): 
		 call(private byte[] MediaUtil.internalReadMediaAsByteArray(byte[],InputStream,int, byte[]))&& (withincode(public byte[] MediaUtil.readMediaAsByteArray(String))&&(args(mediaFile)));
	
	declare soft: IOException: call(private byte[] MediaUtil.internalReadMediaAsByteArray(byte[],InputStream,int, byte[]))&& (withincode(public byte[] MediaUtil.readMediaAsByteArray(String)));
	
	after(String mediaFile) throwing(Exception e) throws  InvalidImageFormatException, ImagePathNotValidException: readInternalMediaAsByteArray(mediaFile){
		if (e instanceof IOException){
			throw new InvalidImageFormatException(
					"The file "+mediaFile+" does not have PNG format");
		}else if (e instanceof NullPointerException){
			throw new ImagePathNotValidException(
					"Path not valid for this image:"+mediaFile);
		}
	}
	
	//Method public ImageData ImageUtil.getImageInfoFromBytes(byte[] bytes) 1- block - Scenario 1
	pointcut getMediaInfoFromBytes(): 
		 execution(public MediaData MediaUtil.getMediaInfoFromBytes(byte[]));
	
	after() throwing(Exception e) throws  InvalidArrayFormatException: getMediaInfoFromBytes(){
		throw new InvalidArrayFormatException();
	}
	
	//Method public byte[] ImageUtil.getBytesFromImageInfo(ImageData ii) 1- block - Scenario 1
	pointcut getBytesFromMediaInfo(): 
		 execution(public String MediaUtil.getBytesFromMediaInfo(MediaData));
	
	after() throwing(Exception e) throws  InvalidImageDataException: getBytesFromMediaInfo(){
		throw new InvalidImageDataException("The provided data are not valid");
	}
}