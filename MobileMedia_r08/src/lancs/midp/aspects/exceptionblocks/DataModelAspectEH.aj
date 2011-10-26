

package lancs.midp.aspects.exceptionblocks;

import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;
import javax.microedition.rms.RecordStoreNotOpenException;

import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.lib.exceptions.UnavailablePhotoAlbumException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;

public aspect DataModelAspectEH {
	
	//Method public void ImageMediaAccessor.addImageData(String, String, String) 1- block - Scenario 1
	pointcut addMediaData(): 
		 execution(public void MediaAccessor.addMediaData(String, String, String));
	
	declare soft: RecordStoreException : addMediaData();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: addMediaData(){
		throw new  PersistenceMechanismException();
	}
	
	//public String[] ImageMediaAccessor.loadImageDataFromRMS(String) 1- block - Scenario 3
	pointcut loadMediaDataFromRMS(): 
		 execution(public MediaData[] MediaAccessor.loadMediaDataFromRMS(String));
	
	declare soft: RecordStoreException : loadMediaDataFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: loadMediaDataFromRMS(){
		throw new PersistenceMechanismException(e);
	}

	//public boolean ImageMediaAccessor.updateImageInfo(ImageData oldData, ImageData newData) block 1 - Scenario 4
	pointcut updateMediaInfo(): 
		 (call(public RecordStore RecordStore.openRecordStore(String, boolean)) || call(public void RecordStore.setRecord(..)))&& (withincode(public boolean MediaAccessor.updateMediaInfo(MediaData, MediaData)));
	
	declare soft: RecordStoreException : execution(public boolean MediaAccessor.updateMediaInfo(MediaData, MediaData));
	//$$$$$$$$$$$$$$$$$$$$$Check why this advice is not operating$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//after()throwing(Exception e) throws  PersistenceMechanismException: updateImageInfo(){
	//	throw new PersistenceMechanismException(e);
	//}
	
	//public boolean ImageMediaAccessor.updateImageInfo(ImageData oldData, ImageData newData) block 2 - Scenario 6
	pointcut updateMediaInfoAround(): 
		 call(public void RecordStore.closeRecordStore(..))&& (withincode(public boolean MediaAccessor.updateMediaInfo(MediaData, MediaData)));
	
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Verify why not $$$$$$$$$$$$$$$$$$$$$$$$
	//void around() throws PersistenceMechanismException: updateImageInfoAround(){
	void around(): updateMediaInfoAround(){
		try{
			proceed();
		} catch (RecordStoreNotOpenException e) {
			//No problem if the RecordStore is not Open
		} //catch (RecordStoreException e) {
		//	throw new PersistenceMechanismException(e);
		//}
	}
	
	//public byte[] ImageMediaAccessor.loadImageBytesFromRMS(String, String,int) 1- block - Scenario 3
	pointcut loadMediaBytesFromRMS(): 
		 execution(public byte[] MediaAccessor.loadMediaBytesFromRMS(String, int));
	
	declare soft: RecordStoreException : loadMediaBytesFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: loadMediaBytesFromRMS(){
		throw new PersistenceMechanismException(e);
	}
	
	//public boolean ImageMediaAccessor.deleteSingleImageFromRMS(String, String) 1- block - Scenario 3
	pointcut deleteSingleMediaFromRMS(): 
		 execution(public boolean MediaAccessor.deleteSingleMediaFromRMS(String, String));
	
	declare soft: RecordStoreException : deleteSingleMediaFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: deleteSingleMediaFromRMS(){
		throw new PersistenceMechanismException(e);
	}
	
	//public void ImageMediaAccessor.createNewPhotoAlbum(String) block 1 - Scenario 4
	pointcut createNewAlbum(): 
		 (call(public RecordStore RecordStore.openRecordStore(String, boolean)) || call(public void RecordStore.closeRecordStore(..)))&& (withincode(public void MediaAccessor.createNewAlbum(String)));

	declare soft: RecordStoreException : createNewAlbum();
	//$$$$$$$$$$$$$$$$$$$$$Check why this advice is not operating$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//after()throwing(Exception e) throws  PersistenceMechanismException: createNewPhotoAlbum(){
	//	throw new PersistenceMechanismException(e);
	//}
	
	//public void ImageMediaAccessor.deletePhotoAlbum(String labelName) 1- block - Scenario 3
	pointcut deleteAlbum(): 
		 execution(public void MediaAccessor.deleteAlbum(String));
	
	declare soft: RecordStoreException : deleteAlbum();
	
	after()throwing(RecordStoreException e) throws PersistenceMechanismException: deleteAlbum(){
		throw new PersistenceMechanismException(e);
	}
	
	//public String[] AlbumData.getAlbumNames() block 1 - Scenario 5
	pointcut getAlbumNames(): 
		 call(public void MediaAccessor.loadAlbums())&& (withincode(public String[] AlbumData.getAlbumNames()));
	
	declare soft:  InvalidImageDataException : getAlbumNames();
	declare soft:  PersistenceMechanismException : getAlbumNames();
	
	void around(): getAlbumNames(){
		try{
			proceed();
		} catch (InvalidImageDataException e) {
			e.printStackTrace();
		} catch (PersistenceMechanismException e) {
			e.printStackTrace();
		}
	}
	
	//public String[] AlbumData.getMedias(String recordName) block 1 - Scenario 3
	pointcut getMedias(): 
		 execution(public MediaData[] AlbumData.getMedias(String));
	
	declare soft:   PersistenceMechanismException : getMedias();
	declare soft:   InvalidImageDataException : getMedias();
	
	after()throwing(Exception e) throws  UnavailablePhotoAlbumException: getMedias(){
		if (e instanceof PersistenceMechanismException)
			throw new UnavailablePhotoAlbumException(e);
		else if (e instanceof InvalidImageDataException)
			throw new UnavailablePhotoAlbumException(e);
	}
	
	//public void AlbumData.resetImageData() block 1 - Scenario 1
	pointcut resetMediaData(): 
		execution(public void AlbumData.resetMediaData());
	
	declare soft:InvalidImageDataException: resetMediaData();
	
	void around(): resetMediaData() {
		try{
			proceed();
		} catch (InvalidImageDataException e) {
			e.printStackTrace();
		}
	}
	
 }
