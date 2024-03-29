/*
 * Created on 12-Apr-2005
 *
 */

package ubc.midp.mobilephoto.sms;

import javax.microedition.lcdui.Alert;
import javax.microedition.lcdui.AlertType;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.List;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.MainUIMidlet;
import ubc.midp.mobilephoto.core.ui.controller.AbstractController;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;

/**
 * @author trevor
 *
 * This class extends the BaseController to provide functionality specific to
 * the SMS (Short Message Service) photo messaging feature. It contains command 
 * handlers for this feature and methods that are only required by this feature. 
 * All non-SMS commands (ie. general ones) are passed on to the parent class (BaseController) 
 * for handling.
 * 
 */
public class SmsSenderController extends AbstractController {

	String imageName = "";
    NetworkScreen networkScreen;

	/**
	 * @param midlet
	 * @param nextController
	 * @param albumData
	 * @param albumListScreen
	 * @param currentScreenName
	 */
	public SmsSenderController(MainUIMidlet midlet, AlbumData albumData, List albumListScreen, String imageName) {
		super(midlet, albumData, albumListScreen);
		this.imageName = imageName;
	}

 	/**
	 * Handle SMS specific events.
	 * If we are given a standard command that is handled by the BaseController, pass 
	 * the handling off to our super class with the else clause
	 */

	public boolean handleCommand(Command c) {
		String label = c.getLabel();
      	System.out.println("SmsSenderController::handleCommand: " + label);
		
		/** Case: ... **/
		if (label.equals("Send Photo by SMS")) {
		    networkScreen = new NetworkScreen("Reciever Details");
			networkScreen.setCommandListener(this);
	      	this.setCurrentScreen(networkScreen);
      		return true;
	      } else if (label.equals("Send Now")) {
	      	
	      	//Get the data from the currently selected image
	      	MediaData ii = null;
	      	byte[] imageBytes = null;
			try {
				ii = getAlbumData().getMediaInfo(imageName);
				imageBytes = getAlbumData().loadMediaBytesFromRMS(ii.getParentAlbumName(), ii.getForeignRecordId());
			} catch (ImageNotFoundException e) {
				Alert alert = new Alert( "Error", "The selected image can not be found", null, AlertType.ERROR);
		        alert.setTimeout(5000);
			} catch (PersistenceMechanismException e) {
				Alert alert = new Alert( "Error", "It was not possible to recovery the selected image", null, AlertType.ERROR);
		        alert.setTimeout(5000);
			}

		  	System.out.println("SmsController::handleCommand - Sending bytes for image " + ii.getMediaLabel() + " with length: " + imageBytes.length);
		  	
			//Get the destination info - set some defaults just in case
			String smsPort = "1000";
			String destinationAddress = "5550001";
			String messageText = "Binary Message (No Text)";

	      	smsPort = networkScreen.getRecPort();
	      	destinationAddress = networkScreen.getRecPhoneNum();

	      	System.out.println("SmsController:handleCommand() - Info from Network Screen is: " + smsPort + " and " + destinationAddress);
	      	
			SmsSenderThread smsS = new SmsSenderThread(smsPort,destinationAddress,messageText);
			smsS.setBinaryData(imageBytes);
			new Thread(smsS).start();
      		return true;
			
	  
	      } else if (label.equals("Cancel Send")) {
	      	
	      	//TODO: If they want to cancel sending the SMS message, send them back to main screen
	      	System.out.println("Cancel sending of SMS message");
      		return true;
	      	
	      } 
	      
  		return false;
	}
}