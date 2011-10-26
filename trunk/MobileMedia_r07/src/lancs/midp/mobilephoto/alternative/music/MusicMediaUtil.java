// [NC] Added in the scenario 07
package lancs.midp.mobilephoto.alternative.music;

import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import ubc.midp.mobilephoto.core.ui.datamodel.MediaData;
import ubc.midp.mobilephoto.core.util.MediaUtil;

public class MusicMediaUtil extends MediaUtil {

	public String getBytesFromMediaInfo(MediaData ii)
			throws InvalidImageDataException {
		try {
			String mediadata = super.getBytesFromMediaInfo(ii);
			if (ii instanceof MultiMediaData) {
				String byteString = new String(mediadata);
				byteString = byteString.concat(DELIMITER);

				byteString = byteString.concat(((MultiMediaData) ii).getTypeMedia());
				System.out.println("Esta salvando o seguinte"+byteString);
				return byteString;
			}
			return mediadata;
		} catch (Exception e) {
			throw new InvalidImageDataException(
					"The provided data are not valid");
		}
	}

	public MediaData getMultiMediaInfoFromBytes(byte[] bytes)
			throws InvalidArrayFormatException {
		MediaData mediadata =  super.getMediaInfoFromBytes(bytes);
		String iiString = new String(bytes);
		System.out.println("Obteve o ENDLINE:"+endIndex+", para:"+iiString);
		int startIndex = endIndex + 1;
		if (endIndex==iiString.length())
			return mediadata;
		
		endIndex = iiString.indexOf(DELIMITER, startIndex);
		
		if (endIndex == -1)
			endIndex = iiString.length();
		String mediaType = iiString.substring(startIndex, endIndex);
		System.out.println("Obteve o seguinte tipo de media Type:"+mediaType);
		MultiMediaData mmedi = new MultiMediaData(mediadata,mediaType);
		return mmedi;
	}
}
