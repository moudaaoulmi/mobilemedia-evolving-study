/*
 * Created on Sep 28, 2004
 */
package ubc.midp.mobilephoto.core.ui.datamodel;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidPhotoAlbumNameException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.lib.exceptions.UnavailablePhotoAlbumException;

/**
 * @author tyoung
 * 
 * This class represents the data model for Photo Albums. A Photo Album object
 * is essentially a list of photos or images, stored in a Hashtable. Due to
 * constraints of the J2ME RecordStore implementation, the class stores a table
 * of the images, indexed by an identifier, and a second table of image metadata
 * (ie. labels, album name etc.)
 * 
 * This uses the ImageAccessor class to retrieve the image data from the
 * recordstore (and eventually file system etc.)
 */
public abstract class AlbumData {

	protected MediaAccessor mediaAccessor;
	
	/**
	 *  Load any photo albums that are currently defined in the record store
	 */
	public String[] getAlbumNames() {

		//Shouldn't load all the albums each time
		//Add a check somewhere in ImageAccessor to see if they've been
		//loaded into memory already, and avoid the extra work...
		mediaAccessor.loadAlbums();
		return mediaAccessor.getAlbumNames();
	}

	/**
	 *  Get all images for a given Photo Album that exist in the Record Store.
	 * @throws UnavailablePhotoAlbumException 
	 * @throws InvalidImageDataException 
	 * @throws PersistenceMechanismException 
	 */
	public MediaData[] getMedias(String recordName) throws UnavailablePhotoAlbumException  {
		MediaData[] result;
		result = mediaAccessor.loadMediaDataFromRMS(recordName);
		return result;
	}

	/**
	 *  Define a new user photo album. This results in the creation of a new
	 *  RMS Record store.
	 * @throws PersistenceMechanismException 
	 * @throws InvalidPhotoAlbumNameException 
	 */
	public void createNewAlbum(String albumName) throws PersistenceMechanismException, InvalidPhotoAlbumNameException {
		mediaAccessor.createNewAlbum(albumName);
	}
	
	public void deleteAlbum(String albumName) throws PersistenceMechanismException{
		mediaAccessor.deleteAlbum(albumName);
	}


	public void addNewMediaToAlbum(String label, String path, String album) throws InvalidImageDataException, PersistenceMechanismException{
		mediaAccessor.addMediaData(label, path, album);
	}

	/**
	 *  Delete a photo from the photo album. This permanently deletes the image from the record store
	 * @throws ImageNotFoundException 
	 * @throws PersistenceMechanismException 
	 */
	public void deleteMedia(String mediaName, String storeName) throws PersistenceMechanismException, ImageNotFoundException {
			mediaAccessor.deleteSingleMediaFromRMS(mediaName, storeName);
	}
	
	/**
	 *  Reset the image data for the application. This is a wrapper to the ImageAccessor.resetImageRecordStore
	 *  method. It is mainly used for testing purposes, to reset device data to the default album and photos.
	 * @throws PersistenceMechanismException 
	 * @throws InvalidImageDataException 
	 */
	public void resetMediaData() throws PersistenceMechanismException {
		mediaAccessor.resetRecordStore();
	}
	
	/**
	 * @param imageName
	 * @return
	 * @throws ImageNotFoundException
	 */
	public MediaData getMediaInfo(String imageName) throws ImageNotFoundException {
		return mediaAccessor.getMediaInfo(imageName);
	}

	/**
	 * @param recordName
	 * @return
	 * @throws PersistenceMechanismException
	 * @throws InvalidImageDataException
	 */
	public MediaData[] loadMediaDataFromRMS(String recordName) throws PersistenceMechanismException, InvalidImageDataException {
		return mediaAccessor.loadMediaDataFromRMS(recordName);
	}

	/**
	 * @param oldData
	 * @param newData
	 * @return
	 * @throws InvalidImageDataException
	 * @throws PersistenceMechanismException
	 */
	public boolean updateMediaInfo(MediaData oldData, MediaData newData) throws InvalidImageDataException, PersistenceMechanismException {
		return mediaAccessor.updateMediaInfo(oldData, newData);
	}

	/**
	 * @param recordName
	 * @param recordId
	 * @return
	 * @throws PersistenceMechanismException
	 */
	public byte[] loadMediaBytesFromRMS(String recordName, int recordId) throws PersistenceMechanismException {
		return mediaAccessor.loadMediaBytesFromRMS(recordName, recordId);
	}
}