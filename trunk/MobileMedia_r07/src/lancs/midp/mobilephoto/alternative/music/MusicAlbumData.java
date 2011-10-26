// [NC] Added in the scenario 07
package lancs.midp.mobilephoto.alternative.music;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import ubc.midp.mobilephoto.core.ui.datamodel.AlbumData;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;

import lancs.midp.mobilephoto.lib.exceptions.ImageNotFoundException;
import lancs.midp.mobilephoto.lib.exceptions.PersistenceMechanismException;

public class MusicAlbumData extends AlbumData {
	
	public MusicAlbumData() {
		mediaAccessor = new MusicMediaAccessor();
	}
	
	public InputStream getMusicFromRecordStore(String recordStore, String musicName) throws ImageNotFoundException, PersistenceMechanismException {
		MediaData mediaInfo = null;
		mediaInfo = mediaAccessor.getMediaInfo(musicName);
		//Find the record ID and store name of the image to retrieve
		int mediaId = mediaInfo.getForeignRecordId();
		String album = mediaInfo.getParentAlbumName();
		//Now, load the image (on demand) from RMS and cache it in the hashtable
		byte[] musicData = (mediaAccessor).loadMediaBytesFromRMS(album, mediaId);
		return new ByteArrayInputStream(musicData);
	}
}
