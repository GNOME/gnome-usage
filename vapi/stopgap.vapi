[CCode (cprefix = "", lower_case_cprefix = "")]
namespace StopGap {

    [CCode (cheader_filename = "fcntl.h")]
    public const int O_DIRECTORY;
    [CCode (cheader_filename = "fcntl.h")]
    public const int O_CLOEXEC;
    [CCode (cheader_filename = "fcntl.h")]
    public const int AT_FDCWD;
    [CCode (cheader_filename = "fcntl.h", feature_test_macro = "_GNU_SOURCE")]
    public int openat (int dirfd, string path, int oflag, Posix.mode_t mode=0);

}