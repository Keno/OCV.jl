using BinDeps
@BinDeps.setup

opencv_core = library_dependency("opencv_core", aliases = ["libopencv_core","libopencv_core.3.0.0"],
    validate = function(p,h)
        # Check that we don't have opencv version 2
        # Not actually sure if this is a valid way to check this,
        # but it happened to be true of the opecv I have on my system
        Libdl.dlsym_e(h,"cvLine") == C_NULL
    end)
opencv_highgui = library_dependency("opencv_highgui", aliases = ["libopencv_highgui","libopencv_highgui.3.0.0"])
opencv_improc = library_dependency("opencv_imgproc", aliases = ["libopencv_imgproc","libopencv_imgproc.3.0.0"])
opencv_objdetect = library_dependency("opencv_objdetect", aliases = ["libopencv_objdetect","libopencv_objdetect.3.0.0"])
opencv_text = library_dependency("opencv_text", aliases = ["libopencv_text","opencv_text.3.0.0"])

@osx_only begin
  using Homebrew
  provides( Homebrew.HB, "opencv3", opencv_core, os = :Darwin )
end

@BinDeps.install Dict(:opencv_core => :opencv_core, :opencv_highgui => :opencv_highgui,
                      :opencv_imgproc => :opencv_imgproc, :opencv_objdetect => :opencv_objdetect,
                      :opencv_text => :opencv_text)
