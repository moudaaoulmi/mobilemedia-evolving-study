

package lancs.midp.aspects.exceptionblocks;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Display;
import ubc.midp.mobilephoto.core.ui.controller.BaseController;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import lancs.midp.mobilephoto.lib.exceptions.UnavailablePhotoAlbumException;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import javax.microedition.rms.RecordStoreFullException;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Displayable;

public aspect ControllerAspectEH {
	
	//public boolean BaseController.handleCommand(Command c, Displayable d) block 1 - Scenario 5
	pointcut handleCommand1(String nameStore, BaseController controler): 
		 (call(public void AlbumData.deletePhotoAlbum(String)) && args(nameStore) && this(controler))&& (withincode(public boolean BaseController.handleCommand(Command, Displayable)));
	
	declare soft: PersistenceMechanismException : (call(public void AlbumData.deletePhotoAlbum(String)))&& (withincode(public boolean BaseController.handleCommand(Command, Displayable)));
	
	void around(String nameStore, BaseController controler): handleCommand1(nameStore,controler){
		try{
			proceed(nameStore,controler);
		} catch (PersistenceMechanismException e) {
			Alert alert = new Alert( "Error", "The mobile database can not delete this photo album", null, AlertType.ERROR);
	        Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
		}
	}
	
	//public boolean BaseController.handleCommand(Command c, Displayable d) block 2 - Scenario 3
	//The result of this advice does not represent the real result of the method.
//	pointcut handleCommand2(String albumname, BaseController controler): 
//			 (call(public * AlbumData.createNewPhotoAlbum(String)) && args(albumname) && this(controler))&& (withincode(public boolean BaseController.handleCommand(Command, Displayable)));	declare soft: PersistenceMechanismException :call(public * AlbumData.createNewPhotoAlbum(String)) && (withincode(public boolean BaseController.handleCommand(Command, Displayable))); 
//	declare soft: InvalidPhotoAlbumNameException: call(public * AlbumData.createNewPhotoAlbum(String)) && (withincode(public boolean BaseController.handleCommand(Command, Displayable))); 
//	void around(String albumname, BaseController controler): handleCommand2(albumname,controler){
//		try{
//			proceed(albumname,controler);
//		} catch (PersistenceMechanismException e) {
//			Alert alert = null;
//			if (e.getCause() instanceof  RecordStoreFullException)
//				alert = new Alert( "Error", "The mobile database is full", null, AlertType.ERROR);
//			else
//				alert = new Alert( "Error", "The mobile database can not add a new photo album", null, AlertType.ERROR);
//			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
//		} catch (InvalidPhotoAlbumNameException e) {
//			Alert alert = new Alert( "Error", "You have provided an invalid Photo Album name", null, AlertType.ERROR);
//			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
//		}
//	}

	
	//private void BaseController.resetImageData() block 1 - Scenario 3
	pointcut resetImageData(BaseController controler): 
		 execution(private void BaseController.resetImageData())&&this(controler);
	
	declare soft: PersistenceMechanismException :  execution(private void BaseController.resetImageData());
	
	void around(BaseController controler): resetImageData(controler){
		try{
			proceed(controler);
		} catch (PersistenceMechanismException e) {
			Alert alert = null;
			if (e.getCause() instanceof  RecordStoreFullException)
				alert = new Alert( "Error", "The mobile database is full", null, AlertType.ERROR);
			else
				alert = new Alert( "Error", "It is not possible to reset the database", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
		    return;
		}	
	}
	
	//private void BaseController.showImageList(String) block 1 - Scenario 3
	pointcut showImageList(String recordName, BaseController controler): 
		 execution(public void BaseController.showImageList(String))&&this(controler)&&args(recordName);
	
	declare soft: UnavailablePhotoAlbumException :  execution(public void BaseController.showImageList(String));
	
	void around(String recordName, BaseController controler): showImageList(recordName, controler){
		try{
			proceed(recordName,controler);
		}  catch (UnavailablePhotoAlbumException e) {
			Alert alert = new Alert( "Error", "The list of photos can not be recovered", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
		    return;
		}
	}
	
	//public void  BaseController.showImage() block 1 - Scenario 3
	pointcut showImage(BaseController controler): 
		 execution(public void  BaseController.showImage(String))&&this(controler);
	
	declare soft: PersistenceMechanismException : execution(public void  BaseController.showImage(String));
	declare soft: ImageNotFoundException : execution(public void  BaseController.showImage(String));
	
	void around(BaseController controler): showImage(controler){
		try{
			proceed(controler);
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert( "Error", "The selected photo was not found in the mobile device", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
	        return;
		} catch (PersistenceMechanismException e) {
			Alert alert = new Alert( "Error", "The mobile database can open this photo", null, AlertType.ERROR);
			Display.getDisplay(controler.midlet).setCurrent(alert, Display.getDisplay(controler.midlet).getCurrent());
	        return;
		}		
	}
}
