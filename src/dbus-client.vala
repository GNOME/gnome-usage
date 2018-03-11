namespace Usage
{
	public struct stats{
		double bytes_sent;
		double bytes_recv;
	}
	[DBus (name = "org.gnome.GTop.NetStats")]
	public interface NetStats : Object
	{
		public abstract HashTable<int,stats?> get_stats () throws IOError;
		public abstract void init_capture() throws IOError;
		public abstract void set_capture_status() throws IOError;
		public abstract void reset_capture_status() throws IOError;
		/*
		This is preferrable over using a signal callback to inturn set the status in 
		DBus server.

		public signal void set_capture_status();
		public signal void reset_capture_status();
		*/

	}
}