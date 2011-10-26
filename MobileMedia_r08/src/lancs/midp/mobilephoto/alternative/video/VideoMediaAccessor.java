package lancs.midp.mobilephoto.alternative.video;

import java.io.IOException;
import java.io.InputStream;

import javax.microedition.rms.RecordStoreException;

import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import lancs.midp.mobilephoto.alternative.musicvideo.MultiMediaData;
import lancs.midp.mobilephoto.alternative.musicvideo.MusicMediaAccessor;
import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;

public class VideoMediaAccessor  extends MusicMediaAccessor{
	
	public VideoMediaAccessor(AlbumData mod) {
		super("vvp-","vvpi-","My Video Album");
	}
	
	public void resetRecordStore() throws InvalidImageDataException, PersistenceMechanismException {
		removeRecords();
		
		// Now, create a new default album for testing
		//	addVideoData("Fish", default_album_name, this.getClass().getResourceAsStream(name))
		
		MediaData media = null;
		MultiMediaData mmedi = null;
		InputStream is = (InputStream) this.getClass().getResourceAsStream("/images/fish.mpg");
		byte[] video = null;
		try {
			video = inputStreamToBytes(is);
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		System.out.println("Vai adicionar os dados");		
		addVideoData("Fish", default_album_name, video);
		loadMediaDataFromRMS(default_album_name);

		try {
			media = this.getMediaInfo("Fish");
			mmedi = new MultiMediaData(media, "video/mpeg");
			this.updateMediaInfo(media, mmedi);
		} catch (ImageNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	public void addVideoData(String videoname, String albumname, byte[] video)
		throws InvalidImageDataException, PersistenceMechanismException {
		try {
			addMediaArrayOfBytes(videoname, albumname, video);
		} catch (RecordStoreException e) {
			throw new PersistenceMechanismException();
		}
	}
	
	public byte[] inputStreamToBytes(InputStream inputStream) throws IOException {
		String str=inputStream.toString();
		return str.getBytes();

	}
}