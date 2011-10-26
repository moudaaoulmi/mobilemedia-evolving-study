package lancs.midp.mobilephoto.optional.capturevideo;

import java.io.ByteArrayOutputStream;

import javax.microedition.lcdui.Command;
import javax.microedition.media.control.RecordControl;

import ubc.midp.mobilephoto.core.ui.controller.MediaController;
import ubc.midp.mobilephoto.core.ui.screens.AlbumListScreen;
import ubc.midp.mobilephoto.core.ui.screens.MediaListScreen;
import lancs.midp.mobilephoto.optional.capturephotoandvideo.CaptureVideoScreen;

public privileged aspect CaptureVideoAspect {
	private Command start = new Command("Start", Command.EXIT, 1);
	private Command stop = new Command("Stop", Command.ITEM, 1);
	
	//public CaptureVideoScreen.CaptureVideoScreen(Image)
	pointcut constructor() :
		call(CaptureVideoScreen.new(..));

	after() returning (CaptureVideoScreen listScreen): constructor() {
		// [NC] Added in the scenario 08
		if (listScreen.typescreen == CAPTUREVIDEO){
			listScreen.addCommand(start);
			listScreen.addCommand(stop);
		}
	}
	
	public void CaptureVideoScreen.startCapture() {
		try {
			if (!recording) {
				rControl = (RecordControl) capturePlayer
						.getControl("RecordControl");
				if (rControl == null)
					throw new Exception("No RecordControl found!");
				byteOfArray = new ByteArrayOutputStream();
				rControl.setRecordStream(byteOfArray);
				rControl.startRecord();
				recording = true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public void CaptureVideoScreen.pauseCapture() {
		try {
			if (recording) {
				rControl.stopRecord();
				rControl.commit();
				recording = false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public byte[] CaptureVideoScreen.getByteArrays() {
		return byteOfArray.toByteArray();
	}
	
	// ********  MediaListScreen  ********* //
	
	// [NC] Added in the scenario 08 
	Command captureVideoCommand = new Command("Capture Video", Command.ITEM, 1);
	
		pointcut initMenu(MediaListScreen screen):
		execution(public void MediaListScreen.initMenu()) && this(screen);
	
	after(MediaListScreen screen) : initMenu(screen) {
		// [NC] Added in the scenario 08 
		if (screen.typeOfScreen == MediaListScreen.PLAYVIDEO)
		{		screen.addCommand(captureVideoCommand);
		}
	}
	
	// ********  MediaController  ********* //
	
	//public boolean handleCommand(Command command)
	pointcut handleCommandAction(MediaController controller, Command c):
		execution(public boolean MediaController.handleCommand(Command)) && args(c) && this(controller);
	
	boolean around(MediaController controller, Command c): handleCommandAction(controller, c) {
		boolean handled = proceed(controller, c);
		
		if (handled) return true;
		
		String label = c.getLabel();
		System.out.println("<* CaptureVideoAspect.around handleCommandAction *> ::handleCommand: " + label);
		
		if (label.equals("Capture Video")) {
			
			CaptureVideoScreen playscree = new CaptureVideoScreen(controller.midlet, CAPTUREVIDEO);
			playscree.setVisibleVideo();
			VideoCaptureController newcontroller = new VideoCaptureController(controller.midlet, controller.getAlbumData(), (AlbumListScreen) controller.getAlbumListScreen(), playscree);
			controller.setNextController(newcontroller);
			playscree.setCommandListener(controller);
			return true;		
		}
		
		return false;
	}
	
	// ********  CaptureVideoScreen  ********* //
	
	public final static int CAPTUREVIDEO = 2;
	
}
