package ubc.midp.mobilephoto.core.util;

import java.io.IOException;
import java.io.InputStream;

import lancs.midp.mobilephoto.lib.exceptions.ImagePathNotValidException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidArrayFormatException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageDataException;
import lancs.midp.mobilephoto.lib.exceptions.InvalidImageFormatException;

import ubc.midp.mobilephoto.core.ui.datamodel.ImageData;

/**
 * @author trevor This is a utility class. It performs conversions between Image
 *         objects and byte arrays, and Image metadata objects and byte arrays.
 *         Byte arrays are the main format for storing data in RMS, and for
 *         sending data over the wire.
 */
public class ImageUtil {

	// Delimiter used in record store data to separate fields in a string.
	public static final String DELIMITER = "*";

	/**
	 * Constructor
	 */
	public ImageUtil() {
		super();
	}

	/**
	 * This method reads an Image from an Input Stream and converts it from a
	 * standard image file format into a byte array, so that it can be
	 * transported over wireless protocols such as SMS
	 * 
	 * @throws ImagePathNotValidException
	 * @throws InvalidImageFormatException
	 */
	public byte[] readImageAsByteArray(String imageFile)
			throws ImagePathNotValidException, InvalidImageFormatException {

		byte bArray[] = new byte[1000];

		// Read an Image into a byte array
		// Required to transfer images over SMS
		InputStream is = null;
		is = (InputStream) this.getClass().getResourceAsStream(imageFile);
		
		int len = 0;
		byte b[] = new byte[1];
		bArray = internalReadImageAsByteArray(bArray, is, len, b);
		return bArray;
	}

	/**
	 * [NC] Add in scenario 01 in order to expose join point
	 * @param bArray
	 * @param is
	 * @param len
	 * @param b
	 * @return
	 * @throws IOException
	 */
	private byte[] internalReadImageAsByteArray(byte[] bArray, InputStream is,
			int len, byte[] b) throws IOException {
		int i;
		byte[] bArray2;
		while (is.read(b) != -1) {

			if (len + 1 >= bArray.length) {

				bArray2 = new byte[bArray.length];

				// Transfer all data from old array to temp array
				for (i = 0; i < len; i++)
					bArray2[i] = bArray[i];

				bArray = new byte[bArray2.length + 500];

				// Re-Copy contents back into new bigger array
				for (i = 0; i < len; i++)
					bArray[i] = bArray2[i];
			}

			// Set the size to be exact
			bArray[len] = b[0];
			len++;
		}

		is.close();
		return bArray;
	}

	/**
	 * 
	 * Convert the byte array from a retrieved RecordStore record into the
	 * ImageInfo ((renamed ImageData) object Order of the string will look like
	 * this: <recordId>*<foreignRecordId>*<labelName>*<imageLabel> Depending
	 * on the optional features, additional fields may be: <phoneNum>
	 * 
	 * @throws InvalidArrayFormatException
	 */
	public ImageData getImageInfoFromBytes(byte[] bytes)
			throws InvalidArrayFormatException {

			String iiString = new String(bytes);

			// Track our position in the String using delimiters
			// Ie. Get chars from beginning of String to first Delim
			int startIndex = 0;
			int endIndex = iiString.indexOf(DELIMITER);

			// Get recordID int value as String - everything before first
			// delimeter
			String intString = iiString.substring(startIndex, endIndex);

			// Get 'foreign' record ID corresponding to the image table
			startIndex = endIndex + 1;
			endIndex = iiString.indexOf(DELIMITER, startIndex);
			String fidString = iiString.substring(startIndex, endIndex);

			// Get Album name (recordstore) - next delimeter
			startIndex = endIndex + 1;
			endIndex = iiString.indexOf(DELIMITER, startIndex);
			String albumLabel = iiString.substring(startIndex, endIndex);

			startIndex = endIndex + 1;
			endIndex = iiString.indexOf(DELIMITER, startIndex);
			
			if (endIndex == -1) 
				endIndex = iiString.length();
			
			String imageLabel = "";
			imageLabel = iiString.substring(startIndex, endIndex);

			// TODO: Add preprocessor statements here

			// [EF] This if statement (and everything inside) can be removed
			// Get the phone number if one exists
//			if ((endIndex + 1) < iiString.length()) {
//				startIndex = endIndex + 1;
//				endIndex = iiString.indexOf(DELIMITER, startIndex);
//				if (endIndex == -1)
//					endIndex = iiString.length();
//
//				iiString.substring(startIndex, endIndex);
//			}

			ImageData ii = createImageData(fidString, albumLabel, imageLabel, endIndex, iiString);
			ii.setRecordId(Integer.parseInt(intString));
			return ii;
	}

	/**
	 * [EF] Scenario 2: extracted to expose join point (aspect CountViewsAspect)
	 * @param fidString
	 * @param albumLabel
	 * @param imageLabel
	 * @param endIndex
	 * @param iiString
	 * @return
	 */
	ImageData createImageData(String fidString, String albumLabel, String imageLabel, int endIndex, String iiString) {
		Integer x = Integer.valueOf(fidString);
		ImageData ii = new ImageData(x.intValue(), albumLabel, imageLabel);
		return ii;
	}
	
	/**
	 * 
	 * Convert the ImageInfo (renamed ImageData) object into bytes so we can
	 * store it in RMS Order of the string will look like this: <recordId>*<foreignRecordId>*<labelName>*<imageLabel>
	 * Depending on the optional features, additional fields may be: <phoneNum>
	 * @throws InvalidImageDataException 
	 */
	public String getBytesFromImageInfo(ImageData ii) throws InvalidImageDataException {

		// Take each String and get the bytes from it, separating fields with a
		// delimiter
		
			String byteString = new String();

			// Convert the record ID for this record
			int i = ii.getRecordId();
			Integer j = new Integer(i);
			byteString = byteString.concat(j.toString());
			byteString = byteString.concat(DELIMITER);

			// Convert the 'Foreign' Record ID field for the corresponding Image
			// record store
			int i2 = ii.getForeignRecordId();
			Integer j2 = new Integer(i2);
			byteString = byteString.concat(j2.toString());
			byteString = byteString.concat(DELIMITER);

			// Convert the album name field
			byteString = byteString.concat(ii.getParentAlbumName());
			byteString = byteString.concat(DELIMITER);

			// Convert the label (name) field
			byteString = byteString.concat(ii.getImageLabel());

			// TODO: Add pre-processor statements
			// Convert the phone number field
			return byteString;
	}

}