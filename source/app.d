
import darg;
import std.algorithm;
import std.conv;
import std.exception;
import std.regex;
import std.stdio;

struct Options
{
	@Option("help")
	@Help("Prints this help.")
	OptionFlag help;

	@Option("frames", "f")
	@Help("Number of frames to leave")
	size_t frames_to_process = size_t.max;

	@Option("width", "w")
	@Help("New width of sequence")
	size_t width = size_t.max;

	@Option("height", "h")
	@Help("New height of sequence")
	size_t height = size_t.max;

	@Argument("<input-file>")
	@Help("Input file")
	string input_file;

	@Argument("<output-file>")
	@Help("Output file")
	string output_file;
}

class App
{
	void run(string[] args)
	{
		auto options = parseArgs!Options(args[1..$]);
		int w,h;
		parse_width_height(options.input_file, w, h);

		auto fd_in = File(options.input_file, "rb");
		auto fd_out = File(options.output_file, "wb");
		auto buf = new ubyte[w*h + w*h/2];
		auto nw = min(options.width, w);
		auto nh = min(options.height, h);

		for(int cnt=0; cnt<options.frames_to_process; ++cnt)
		{
			auto r = fd_in.rawRead(buf);
			if(r.length != buf.length)
			{
				if(r.length != 0) writefln("failed to read full frame (invalid width/height?)");
				break;
			}

			int dc = 0;
			foreach(cc; 0..3)
			{
				int scale = cc==0?1:2;
				for(int y=0; y<nh/scale; ++y)
					fd_out.rawWrite(buf[dc +y*w/scale..dc+y*w/scale+nw/scale]);
				dc += cc==0?w*h:w*h/4;
			}
		}
		fd_in.close();
		fd_out.close();
	}

	void parse_width_height(string s, ref int w, ref int h)
	{
		auto r = regex(r"(\d+)x(\d+)+");
		auto c = matchFirst(s, r);
		enforce(c, "failed to deduce video size from filename (using WxH entry)");
		w = to!int(c[1]);
		h = to!int(c[2]);
	}
}

int main(string[] args)
{
	immutable usage = usageString!Options("example");
	immutable help = helpString!Options;

	try
	{
		auto app = new App;
		app.run(args);
		return 0;
	}
	catch (ArgParseError e)
	{
		writeln(e.msg);
		writeln(usage);
		return 1;
	}
	catch (ArgParseHelp e)
	{
		// Help was requested
		writeln(usage);
		write(help);
		return 0;
	}

}
