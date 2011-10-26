

package lancs.midp.aspects.exceptionblocks;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;

import lancs.midp.mobilephoto.alternative.photo.PhotoViewScreen;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;

public aspect SCreensAspectEH {

	//Method public PhotoViewScreen.new 1- block - Scenario 1
	pointcut PhotoViewScreenConstructor(AlbumData mod, String name): 
	     execution(public PhotoViewScreen.new(AlbumData, String))&&(args(mod,name));
	
	declare soft: ImageNotFoundException: execution(public PhotoViewScreen.new(AlbumData, String));
	declare soft: PersistenceMechanismException: execution(public PhotoViewScreen.new(AlbumData, String));
	
	void around(AlbumData mod, String name): PhotoViewScreenConstructor(mod, name){
		try{
			proceed(mod, name);
		} catch (ImageNotFoundException e) {
			Alert alert = new Alert( "Error", "The selected image can not be found", null, AlertType.ERROR);
			alert.setTimeout(5000);
		} catch (PersistenceMechanismException e) {
			Alert alert = new Alert( "Error", "It was not possible to recovery the selected image", null, AlertType.ERROR);
			alert.setTimeout(5000);
		}
	}
}
