// [NC] Added in the scenario 08
package lancs.midp.mobilephoto.optional.capturephotoandvideo;

import java.io.ByteArrayOutputStream;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Graphics;
import javax.microedition.lcdui.game.GameCanvas;
import javax.microedition.media.Manager;
import javax.microedition.media.MediaException;
import javax.microedition.media.Player;
import javax.microedition.media.control.RecordControl;
import javax.microedition.media.control.VideoControl;

import ubc.midp.mobilephoto.core.ui.MainUIMidlet;

public class CaptureVideoScreen extends GameCanvas {
	Player capturePlayer = null;

	Display display = null;

	private VideoControl videoControl = null;
	private RecordControl rControl = null;
	ByteArrayOutputStream byteOfArray = new ByteArrayOutputStream();
	
	private Command back = new Command("Back", Command.ITEM, 1);

	boolean recording = false;
	private int typescreen = 0;

	public CaptureVideoScreen(MainUIMidlet midlet, int type) {
		super(false);
		
//		typescreen = type;

		display = Display.getDisplay(midlet);

		try {
			capturePlayer = Manager.createPlayer("capture://video");
			capturePlayer.realize();
		} catch (Exception e) {
			e.printStackTrace();
		}

		videoControl = (VideoControl) capturePlayer
				.getControl("javax.microedition.media.control.VideoControl");
		try {
			if (videoControl == null)
				throw new Exception("No Video Control for capturing!");

			videoControl.initDisplayMode(VideoControl.USE_DIRECT_VIDEO, this);
			videoControl.setDisplayFullScreen(true);
		} catch (MediaException me) {
			videoControl.setDisplayLocation(5, 5);
			try {
				videoControl.setDisplaySize(getWidth() - 10, getHeight() - 10);
			} catch (Exception e) {
			}
			repaint();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		this.addCommand(back);
	}

	public void keyPressed(int keyCode) {

	}

	public void paint(Graphics g) {
		g.setColor(0xffffff);
		g.fillRect(0, 0, getWidth(), getHeight());
		g.setColor(0x44ff66);
		g.drawRect(2, 2, getWidth() - 4, getHeight() - 4);
	}

	public void setVisibleVideo() {
		display.setCurrent(this);
		videoControl.setVisible(true);
		try {
			capturePlayer.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
