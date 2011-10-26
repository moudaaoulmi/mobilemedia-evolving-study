package lancs.midp.mobilephoto.optional.smsorcapturephotoorvideo;

import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.ui.screens.AddMediaToAlbum;
import lancs.midp.mobilephoto.alternative.photo.PhotoViewScreen;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.optional.copyPhoto.PhotoViewController;

public aspect SmsOrCapturePhotoOrVideo {
	 private byte[] AddMediaToAlbum.CapturedMedia = null;
	 
	 private byte[] PhotoViewScreen.byteImage = null;
	 
	 public byte[] AddMediaToAlbum.getCapturedMedia() {
			return CapturedMedia;
		}

	public void AddMediaToAlbum.setCapturedMedia(byte[] capturedMedia) {
			CapturedMedia = capturedMedia;
	}
	
	public byte[] PhotoViewScreen.getImage(){
		return byteImage;
	}
	
	public void PhotoViewScreen.setImage(byte[] img){
		byteImage = img;
	}
	
	// ********  PhotoViewController  ********* //
	
	pointcut processCopy(PhotoViewController photoViewController, AddMediaToAlbum copyPhotoToAlbum):
		execution(private void PhotoViewController.processCopy(AddMediaToAlbum))
		&& this(photoViewController) && args(copyPhotoToAlbum);
	
	after(PhotoViewController photoViewController, AddMediaToAlbum copyPhotoToAlbum): processCopy(photoViewController, copyPhotoToAlbum) {
		if (((PhotoViewScreen)photoViewController.getCurrentScreen()).isFromSMS()){
			copyPhotoToAlbum.setCapturedMedia(((PhotoViewScreen)photoViewController.getCurrentScreen()).getImage());
		}
	}

	pointcut processImageData(PhotoViewController photoViewController, String photoName, String albumname):
		execution(private MediaData PhotoViewController.processImageData(String, String))
		&& this(photoViewController)
		&& args(photoName, albumname);
	
	MediaData around (PhotoViewController photoViewController, String photoName, String albumname) throws InvalidImageDataException, PersistenceMechanismException :
		          processImageData(photoViewController,photoName, albumname) {
		MediaData imageData = null;
		byte[] imgByte= ((AddMediaToAlbum)photoViewController.getCurrentScreen()).getCapturedMedia();
		if (imgByte == null){
		   imageData = proceed(photoViewController, photoName, albumname);
		}else{
			photoViewController.getAlbumData().addImageData(photoName, imgByte, albumname);
		}		
		return imageData;
	}
}
