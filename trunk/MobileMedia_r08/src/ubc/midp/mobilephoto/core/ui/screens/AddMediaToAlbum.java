package ubc.midp.mobilephoto.core.ui.screens;

import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.Form;
import javax.microedition.lcdui.TextField;

public class AddMediaToAlbum extends Form {
	
	TextField labeltxt = new TextField("Item label", "", 15, TextField.ANY);
	TextField itempathtxt = new TextField("Path", "", 20, TextField.ANY);
	
	Command ok;
	Command cancel;

	public AddMediaToAlbum(String title) {
		super(title);
		this.append(labeltxt);
		this.append(itempathtxt);
		
		ok = new Command("Save Item", Command.SCREEN, 0);
		cancel = new Command("Cancel", Command.EXIT, 1);
		this.addCommand(ok);
		this.addCommand(cancel);
	}
	
	public String getItemName(){
		return labeltxt.getString();
	}
	
	/**
	 * [EF] Added in scenario 05 in order to reuse this screen in the Copy Photo functionality
	 * @param photoName
	 */
	public void setItemName(String itemName) {
		labeltxt.setString(itemName);
	}
	
	public String getPath() {
		return itempathtxt.getString();
	}

	/**
	 * [EF] Added in scenario 05 in order to reuse this screen in the Copy Photo functionality
	 * @param photoName
	 */
	public void setLabePath(String label) {
		itempathtxt.setLabel(label);
	}
}
