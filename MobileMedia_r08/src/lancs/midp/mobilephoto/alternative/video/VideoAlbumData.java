package lancs.midp.mobilephoto.alternative.video;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;
import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;

public class VideoAlbumData extends AlbumData{
	
	public VideoAlbumData() {
		mediaAccessor = new VideoMediaAccessor(this);
	}
	
	public InputStream getVideoFromRecordStore(String recordStore, String musicName) throws ImageNotFoundException, PersistenceMechanismException {
		MediaData mediaInfo = null;
		mediaInfo = mediaAccessor.getMediaInfo(musicName);
		//Find the record ID and store name of the image to retrieve
		int mediaId = mediaInfo.getForeignRecordId();
		String album = mediaInfo.getParentAlbumName();
		//Now, load the image (on demand) from RMS and cache it in the hashtable
		byte[] musicData = (mediaAccessor).loadMediaBytesFromRMS(album, mediaId);
		return new ByteArrayInputStream(musicData);

	}
	public void addVideoData(String videoname, String albumname, byte[] video)
	throws InvalidImageDataException, PersistenceMechanismException {
		((VideoMediaAccessor)mediaAccessor).addVideoData(videoname, albumname, video);
	}

}