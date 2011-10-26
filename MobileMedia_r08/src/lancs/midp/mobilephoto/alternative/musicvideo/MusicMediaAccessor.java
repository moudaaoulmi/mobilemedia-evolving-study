// [NC] Added in the scenario 07
package lancs.midp.mobilephoto.alternative.musicvideo;

import ubc.midp.mobilephoto.core.ui.datamodel.MediaAccessor;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import lancs.midp.mobilephoto.alternative.music.MusicMediaUtil;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageFormatException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;

public class MusicMediaAccessor extends MediaAccessor {

	private MusicMediaUtil converter = new MusicMediaUtil();
	
	public MusicMediaAccessor() {
		super("mmp-","mmpi-","My Music Album");
	}
	
	public MusicMediaAccessor(String album_label, String info_label, String default_album_name) {
		super(album_label,info_label,default_album_name);
	}
	
	protected  byte[] getMediaArrayOfByte(String path)	throws ImagePathNotValidException, InvalidImageFormatException {
		byte[] data1 = converter.readMediaAsByteArray(path);
		return data1;
	}
	
	protected byte[] getByteFromMediaInfo(MediaData ii) throws InvalidImageDataException {
			return converter.getBytesFromMediaInfo(ii).getBytes();
	}
	
	protected MediaData getMediaFromBytes(byte[] data) throws InvalidArrayFormatException {
		MediaData iiObject = converter.getMultiMediaInfoFromBytes(data);
		return iiObject;
	}

	public void resetRecordStore() throws InvalidImageDataException, PersistenceMechanismException {
		removeRecords();
		// Now, create a new default album for testing
		MediaData media = null;
		MultiMediaData mmedi = null;

		addMediaData("Applause", "/images/applause.wav", default_album_name);
		addMediaData("Baby", "/images/baby.wav", default_album_name);
		addMediaData("Bong", "/images/bong.wav", default_album_name);
		addMediaData("Frogs", "/images/frogs.mp3", default_album_name);
		addMediaData("Jump", "/images/jump.wav", default_album_name);
		addMediaData("Printer", "/images/printer.wav", default_album_name);
		addMediaData("Tango", "/images/cabeza.mid", default_album_name);
		
		loadMediaDataFromRMS(default_album_name);
		try {
			media = this.getMediaInfo("Applause");

			mmedi = new MultiMediaData(media, "audio/x-wav");
			this.updateMediaInfo(media, mmedi);

			media = this.getMediaInfo("Baby");
			mmedi = new MultiMediaData(media, "audio/x-wav");
			this.updateMediaInfo(media, mmedi);

			media = this.getMediaInfo("Bong");
			mmedi = new MultiMediaData(media, "audio/x-wav");
			this.updateMediaInfo(media, mmedi);

			media = this.getMediaInfo("Frogs");
			mmedi = new MultiMediaData(media, "audio/mpeg");
			this.updateMediaInfo(media, mmedi);

			media = this.getMediaInfo("Jump");
			mmedi = new MultiMediaData(media, "audio/x-wav");
			this.updateMediaInfo(media, mmedi);

			media = this.getMediaInfo("Printer");
			mmedi = new MultiMediaData(media, "audio/x-wav");
			this.updateMediaInfo(media, mmedi);
			
			media = this.getMediaInfo("Tango");
			mmedi = new MultiMediaData(media, "audio/midi");
			this.updateMediaInfo(media, mmedi);
		} catch (ImageNotFoundException e) {
			e.printStackTrace();
		}
	}
}
