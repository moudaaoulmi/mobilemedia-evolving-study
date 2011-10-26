

package lancs.midp.aspects.exceptionblocks;

import javax.microedition.lcdui.Image;
import javax.microedition.rms.RecordStoreException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.NullAlbumDataReference;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.lib.exceptions.UnavailablePhotoAlbumException;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageAccessor;
import javax.microedition.rms.RecordStore;
import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;
import javax.microedition.rms.RecordStoreNotOpenException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;

public aspect DataModelAspectEH {
	
	//Method public void ImageAccessor.addImageData(String, String, String) 1- block - Scenario 1
	pointcut addImageData(): 
		 execution(public void ImageAccessor.addImageData(String, String, String));
	
	declare soft: RecordStoreException : addImageData();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: addImageData(){
		throw new  PersistenceMechanismException();
	}
	
	//public String[] ImageAccessor.loadImageDataFromRMS(String) 1- block - Scenario 3
	pointcut loadImageDataFromRMS(): 
		 execution(public ImageData[] ImageAccessor.loadImageDataFromRMS(String));
	
	declare soft: RecordStoreException : loadImageDataFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: loadImageDataFromRMS(){
		throw new PersistenceMechanismException(e);
	}

	//public boolean ImageAccessor.updateImageInfo(ImageData oldData, ImageData newData) block 1 - Scenario 4
	pointcut updateImageInfo(): 
		 (call(public RecordStore RecordStore.openRecordStore(String, boolean)) || call(public void RecordStore.setRecord(..)))&& (withincode(public boolean ImageAccessor.updateImageInfo(ImageData, ImageData)));
	
	declare soft: RecordStoreException : execution(public boolean ImageAccessor.updateImageInfo(ImageData, ImageData));
	//$$$$$$$$$$$$$$$$$$$$$Check why this advice is not operating$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//after()throwing(Exception e) throws  PersistenceMechanismException: updateImageInfo(){
	//	throw new PersistenceMechanismException(e);
	//}
	
	//public boolean ImageAccessor.updateImageInfo(ImageData oldData, ImageData newData) block 2 - Scenario 6
	pointcut updateImageInfoAround(): 
		 call(public void RecordStore.closeRecordStore(..))&& (withincode(public boolean ImageAccessor.updateImageInfo(ImageData, ImageData)));
	
	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$Verify why not $$$$$$$$$$$$$$$$$$$$$$$$
	//void around() throws PersistenceMechanismException: updateImageInfoAround(){
	void around(): updateImageInfoAround(){
		try{
			proceed();
		} catch (RecordStoreNotOpenException e) {
			//No problem if the RecordStore is not Open
		} //catch (RecordStoreException e) {
		//	throw new PersistenceMechanismException(e);
		//}
	}
	
	//public byte[] ImageAccessor.loadImageBytesFromRMS(String, String,int) 1- block - Scenario 3
	pointcut loadImageBytesFromRMS(): 
		 execution(public byte[] ImageAccessor.loadImageBytesFromRMS(String, String,int));
	
	declare soft: RecordStoreException : loadImageBytesFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: loadImageBytesFromRMS(){
		throw new PersistenceMechanismException(e);
	}
	
	//public boolean ImageAccessor.deleteSingleImageFromRMS(String, String) 1- block - Scenario 3
	pointcut deleteSingleImageFromRMS(): 
		 execution(public boolean ImageAccessor.deleteSingleImageFromRMS(String, String));
	
	declare soft: RecordStoreException : deleteSingleImageFromRMS();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: deleteSingleImageFromRMS(){
		throw new PersistenceMechanismException(e);
	}
	
	//public void ImageAccessor.createNewPhotoAlbum(String) block 1 - Scenario 4
	pointcut createNewPhotoAlbum(): 
		 (call(public RecordStore RecordStore.openRecordStore(String, boolean)) || call(public void RecordStore.closeRecordStore(..)))&& (withincode(public void ImageAccessor.createNewPhotoAlbum(String)));

	declare soft: RecordStoreException : createNewPhotoAlbum();
	//$$$$$$$$$$$$$$$$$$$$$Check why this advice is not operating$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	//after()throwing(Exception e) throws  PersistenceMechanismException: createNewPhotoAlbum(){
	//	throw new PersistenceMechanismException(e);
	//}
	
	//public void ImageAccessor.deletePhotoAlbum(String labelName) 1- block - Scenario 3
	pointcut deletePhotoAlbum(): 
		 execution(public void ImageAccessor.deletePhotoAlbum(String));
	
	declare soft: RecordStoreException : deletePhotoAlbum();
	
	after()throwing(RecordStoreException e) throws  PersistenceMechanismException: deletePhotoAlbum(){
		throw new PersistenceMechanismException(e);
	}
	
	//public String[] AlbumData.getAlbumNames() block 1 - Scenario 5
	pointcut getAlbumNames(): 
		 call(public void ImageAccessor.loadAlbums())&& (withincode(public String[] AlbumData.getAlbumNames()));
	
	declare soft:  InvalidImageDataException : getAlbumNames();
	declare soft:  PersistenceMechanismException : getAlbumNames();
	
	void around(): getAlbumNames(){
		try{
			proceed();
		} catch (InvalidImageDataException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (PersistenceMechanismException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	//public String[] AlbumData.getImages(String recordName) block 1 - Scenario 3
	pointcut getImages(): 
		 execution(public ImageData[] AlbumData.getImages(String));
	
	declare soft:   PersistenceMechanismException : getImages();
	declare soft:   InvalidImageDataException : getImages();
	
	after()throwing(Exception e) throws  UnavailablePhotoAlbumException: getImages(){
		if (e instanceof PersistenceMechanismException)
			throw new UnavailablePhotoAlbumException(e);
		else if (e instanceof InvalidImageDataException)
			throw new UnavailablePhotoAlbumException(e);
	}
	
	//public Image AlbumData.getImageFromRecordStore(String recordStore, String imageName) block 1 - Scenario 5
	pointcut getImageFromRecordStore(String imageName, AlbumData album): 
		 (call(public ImageData ImageAccessor.getImageInfo(String))&& this(album))&& (withincode(public Image AlbumData.getImageFromRecordStore(*, String))&&args(imageName));
	
	declare soft:   NullAlbumDataReference : execution(public Image AlbumData.getImageFromRecordStore(*, String));
	
	ImageData around(String imageName,AlbumData album): getImageFromRecordStore(imageName,album){
		try{
			return proceed(imageName,album);
		} catch (NullAlbumDataReference e) {
			album.setImageAccessor( new ImageAccessor(album) );
			return null;
		}
	}
	
	//public void AlbumData.deleteImage(String imageName, String storeName) block 1 - Scenario 1
	pointcut deleteImage(String imageName, String storeName, AlbumData album): 
		execution(public void AlbumData.deleteImage(String, String)) && args(imageName, storeName) && target(album);
	
	declare soft:NullAlbumDataReference: execution(public void AlbumData.deleteImage(String, String));
	
	void around(String imageName, String storeName, AlbumData album): deleteImage(imageName, storeName, album){
		try{
			proceed(imageName, storeName, album);
		}
		catch (NullAlbumDataReference e) {
			album.setImageAccessor( new ImageAccessor(album) );
			e.printStackTrace();
		} 
	}

	//public void AlbumData.resetImageData() block 1 - Scenario 1
	pointcut resetImageData(): 
		execution(public void AlbumData.resetImageData());
	
	declare soft:InvalidImageDataException: resetImageData();
	
	void around(): resetImageData(){
		try{
			proceed();
		} catch (InvalidImageDataException e) {
			e.printStackTrace();
		}
	}
 }
