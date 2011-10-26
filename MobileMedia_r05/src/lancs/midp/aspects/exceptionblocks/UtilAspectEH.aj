package lancs.midp.aspects.exceptionblocks;

import java.io.IOException;
import java.io.InputStream;

import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageFormatException;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import ubc.midp.mobilephoto.core.util.ImageUtil;

public aspect UtilAspectEH {
	
	//Method ImageUtil.readImageAsByteArray 1- block - Scenario 3
	pointcut readImageAsByteArray(String imageFile): 
		 (call(public void Class.getResourceAsStream(String))&&(args(imageFile)))&& withincode(public byte[] ImageUtil.readImageAsByteArray(String)) ;
	
	after(String imageFile) throwing(Exception e) throws  ImagePathNotValidException: readImageAsByteArray(imageFile){
		throw new ImagePathNotValidException(
				"Path not valid for this image:"+imageFile);
	}
	
	//Method ImageUtil.readImageAsByteArray 2- block - Scenario 3
	pointcut readInternalImageAsByteArray(String imageFile): 
		 call(byte[] ImageUtil.internalReadImageAsByteArray(byte[],InputStream,int, byte[]))&& (withincode(public byte[] ImageUtil.readImageAsByteArray(String))&&(args(imageFile)));
	
	declare soft: IOException: call(byte[] ImageUtil.internalReadImageAsByteArray(byte[],InputStream,int, byte[]))&& (withincode(public byte[] ImageUtil.readImageAsByteArray(String)));
	
	after(String imageFile) throwing(Exception e) throws  InvalidImageFormatException, ImagePathNotValidException: readInternalImageAsByteArray(imageFile){
		if (e instanceof IOException){
			throw new InvalidImageFormatException(
					"The file "+imageFile+" does not have PNG format");
		}else if (e instanceof NullPointerException){
			throw new ImagePathNotValidException(
					"Path not valid for this image:"+imageFile);
		}
	}
	
	//Method public ImageData ImageUtil.getImageInfoFromBytes(byte[] bytes) 1- block - Scenario 1
	pointcut getImageInfoFromBytes(): 
		 execution(public ImageData ImageUtil.getImageInfoFromBytes(byte[]));
	
	after() throwing(Exception e) throws  InvalidArrayFormatException: getImageInfoFromBytes(){
		throw new InvalidArrayFormatException();
	}
	
	//Method public byte[] ImageUtil.getBytesFromImageInfo(ImageData ii) 1- block - Scenario 1
	pointcut  getBytesFromImageInfo(): 
		 execution(public String ImageUtil.getBytesFromImageInfo(ImageData));
	
	after() throwing(Exception e) throws  InvalidImageDataException: getBytesFromImageInfo(){
		throw new InvalidImageDataException("The provided data are not valid");
	}
}