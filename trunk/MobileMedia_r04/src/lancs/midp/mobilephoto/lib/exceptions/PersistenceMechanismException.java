package lancs.midp.mobilephoto.lib.exceptions;



public class PersistenceMechanismException extends Exception {

	private Throwable cause;
	
	public PersistenceMechanismException(String arg0) {
		super(arg0);
	}

	public PersistenceMechanismException() {
	}
	
	public PersistenceMechanismException(Throwable arg0) {
		cause = arg0;
	}
	
	public Throwable getCause(){
		return cause;
	}
}
