module OCV
    using Cxx
    using FixedSizeArrays
    using GeometryTypes
    import Distances: euclidean
    import Base: convert

    include("../deps/deps.jl")
    const cv_headerpath = joinpath(dirname(opencv_core),"../include")

    function __init__()
        addHeaderDir(cv_headerpath, kind = C_System)
        Libdl.dlopen(opencv_core,Libdl.RTLD_GLOBAL)
        Libdl.dlopen(opencv_highgui,Libdl.RTLD_GLOBAL)
        Libdl.dlopen(opencv_imgproc,Libdl.RTLD_GLOBAL)
        Libdl.dlopen(opencv_objdetect,Libdl.RTLD_GLOBAL)
        Libdl.dlopen(opencv_text,Libdl.RTLD_GLOBAL)
    end

    __init__()
    cxx"""
    #include <opencv2/highgui/highgui.hpp>
    #include <opencv2/imgproc/imgproc.hpp>
    #include <opencv2/core/core.hpp>
    """
    @Cxx.list cxxt"std::vector<cv::Vec4i>"

    function toline(line::Union{cxxt"cv::Vec4i",cxxt"cv::Vec4i&"})
        (Point{2,Int32}(icxx"$line[0];",icxx"$line[1];"),
         Point{2,Int32}(icxx"$line[2];",icxx"$line[3];"))
    end

    function tocircle(circle::Union{cxxt"cv::Vec3f",cxxt"cv::Vec3f&"})
        Circle{Float32}(Point{2,Float32}(icxx"$circle[0];",icxx"$circle[1];"),icxx"$circle[2];")
    end

    euclidean(p1::Point{2},p2::Point{2}) = sqrt((p1[1]-p2[1])^2+(p1[2]-p2[2])^2)

    Base.convert{T}(::Type{Point{2,T}},point::cxxt"cv::Point_<$T>") =
        Point{2,T}(icxx"$point.x;",icxx"$point.y;")
    function Base.convert{T}(::Type{HyperRectangle{2,T}},
            rect::Union{cxxt"cv::Rect_<$T>",cxxt"cv::Rect_<$T>&"})
        HyperRectangle{2,T}(icxx"$rect.tl();",
                          icxx"$rect.br();")
    end
    Base.convert{T}(::Type{HyperRectangle},rect::Union{cxxt"cv::Rect_<$T>",cxxt"cv::Rect_<$T>&"}) =
        convert(HyperRectangle{2,T},rect)

    using Images, ColorTypes

    function Base.convert(::Type{cxxt"cv::Mat"}, img::Image)
       src = icxx"""
         cv::Mat{(int)$(size(img)[2]),
                 (int)$(size(img)[1]),CV_8UC3,
                 $(convert(Ptr{Void},pointer(data(convert(Image{BGR},img)))))};
       """
   end


end # module
