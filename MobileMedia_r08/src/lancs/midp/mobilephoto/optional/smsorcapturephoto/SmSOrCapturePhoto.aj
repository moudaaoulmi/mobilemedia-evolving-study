package lancs.midp.mobilephoto.optional.smsorcapturephoto;
import javax.microedition.rms.RecordStoreException;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import lancs.midp.mobilephoto.alternative.photo.ImageMediaAccessor;

public privileged aspect SmSOrCapturePhoto {

	// ********  AlbumData  ********* //
	public void AlbumData.addImageData(String photoname, byte[] imgdata, String albumname)
	throws InvalidImageDataException, PersistenceMechanismException {
		if (mediaAccessor instanceof ImageMediaAccessor)
			((ImageMediaAccessor)mediaAccessor).addImageData(photoname, imgdata, albumname);
	}
	
	// ********  ImageMediaAccessor  ********* //
	public void ImageMediaAccessor.addImageData(String photoname, byte[] imgdata, String albumname)
	throws InvalidImageDataException, PersistenceMechanismException {
		try {
			addMediaArrayOfBytes(photoname, albumname, imgdata);
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}
	}
}
