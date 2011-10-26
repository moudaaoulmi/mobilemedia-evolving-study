// [NC] Added in the scenario 07
package lancs.midp.mobilephoto.alternative.photo;

import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;

import ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.util.MediaUtil;
import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageFormatException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;

public class ImageMediaAccessor extends MediaAccessor {
	
	private MediaUtil converter = new MediaUtil();
	
	public ImageMediaAccessor() {
		super("mpa-","mpi-","My Photo Album");
	}
	
	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor#resetRecordStore()
	 */
	public void resetRecordStore() throws InvalidImageDataException, PersistenceMechanismException {
		String storeName = null;
		String infoStoreName = null;

		// remove any existing album stores...
		if (albumNames != null) {
			for (int i = 0; i < albumNames.length; i++) {
				try {
					// Delete all existing stores containing Image objects as
					// well as the associated ImageInfo objects
					// Add the prefixes labels to the info store

					storeName = album_label + albumNames[i];
					infoStoreName = info_label + albumNames[i];

					System.out.println("<* ImageAccessor.resetImageRecordStore() *> delete "+storeName);
					
					RecordStore.deleteRecordStore(storeName);
					RecordStore.deleteRecordStore(infoStoreName);

				} catch (RecordStoreException e) {
					System.out.println("No record store named " + storeName
							+ " to delete.");
					System.out.println("...or...No record store named "
							+ infoStoreName + " to delete.");
					System.out.println("Ignoring Exception: " + e);
					// ignore any errors...
				}
			}
		} else {
			// Do nothing for now
			System.out
					.println("ImageAccessor::resetImageRecordStore: albumNames array was null. Nothing to delete.");
		}

		// Now, create a new default album for testing
		addMediaData("Tucan Sam", "/images/Tucan.png",
				default_album_name);
		// Add Penguin
		addMediaData("Linux Penguin", "/images/Penguin.png",
				default_album_name);
		// Add Duke
		addMediaData("Duke (Sun)", "/images/Duke1.PNG",
				default_album_name);
		addMediaData("UBC Logo", "/images/ubcLogo.PNG",
				default_album_name);
		// Add Gail
		addMediaData("Gail", "/images/Gail1.PNG",
				default_album_name);
		// Add JG
		addMediaData("J. Gosling", "/images/Gosling1.PNG",
				default_album_name);
		// Add GK
		addMediaData("Gregor", "/images/Gregor1.PNG",
				default_album_name);
		// Add KDV
		addMediaData("Kris", "/images/Kdvolder1.PNG",
				default_album_name);

	}
	
	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor#getMediaArrayOfByte(java.lang.String)
	 */
	protected  byte[] getMediaArrayOfByte(String path)	throws ImagePathNotValidException, InvalidImageFormatException {
		byte[] data1 = converter.readMediaAsByteArray(path);
		return data1;
	}
	
	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor#getByteFromMediaInfo(ubc.midp.mobilephoto.core.ui.datamodel.MediaData)
	 */
	public byte[] getByteFromMediaInfo(MediaData ii) throws InvalidImageDataException {
			return converter.getBytesFromMediaInfo(ii).getBytes();
	}
	
	/* (non-Javadoc)
	 * @see ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor#getMediaFromBytes(byte[])
	 */
	protected MediaData getMediaFromBytes(byte[] data) throws InvalidArrayFormatException {
		MediaData iiObject = converter.getMediaInfoFromBytes(data);
		return iiObject;
	}

	/**
	 * Fetch a single image from the Record Store This should be used for
	 * loading images on-demand (only when they are viewed or sent via SMS etc.)
	 * to reduce startup time by loading them all at once.
	 * @throws PersistenceMechanismException 
	 */
	public Image loadSingleImageFromRMS(String recordName, String imageName,
			int recordId) throws PersistenceMechanismException {
		Image img = null;
		byte[] imageData = loadMediaBytesFromRMS(recordName, recordId);
		img = Image.createImage(imageData, 0, imageData.length);
		return img;
	}
}
