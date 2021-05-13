import os
import os.path
import fnmatch
import logging
from pathlib import Path
# import ycm_core
import re

C_BASE_FLAGS = [
        '-Wall',
        '-Wextra',
        '-Werror',
        '-Wno-long-long',
        '-Wno-variadic-macros',
        '-fexceptions',
        '-ferror-limit=10000',
        '-DNDEBUG',
        '-std=c11',
        '-isystem/usr/lib/',
        '-isystem/usr/include/'
        ]

CPP_BASE_FLAGS = [
        '-Wall',
        '-Wextra',
        '-Wno-long-long',
        '-Wno-variadic-macros',
        '-fexceptions',
        '-ferror-limit=10000',
        '-DNDEBUG',
        '-std=c++11',
        '-xc++',
        '-isystem/usr/lib/',
        '-isystem/usr/include/'
        ]

CUDA_HOME_ENV = os.getenv( 'CUDA_HOME', '/usr/local/cuda' )

CU_BASE_FLAGS = [
        '-Wall',
        '-xcuda',
        '-isystem'+CUDA_HOME_ENV+'/include',
        '-isystem'+CUDA_HOME_ENV+'/lib64'
        ]

C_SOURCE_EXTENSIONS = [
        '.c'
        ]

CPP_SOURCE_EXTENSIONS = [
        '.cpp',
        '.cxx',
        '.cc',
        '.m',
        '.mm'
        ]

CU_SOURCE_EXTENSIONS = [
        '.cu'
        ]

SOURCE_DIRECTORIES = [
        'src',
        'lib'
        ]

HEADER_EXTENSIONS = [
        '.h',
        '.hxx',
        '.hpp',
        '.hh'
        ]

HEADER_DIRECTORIES = [
        'include'
        ]

BUILD_DIRECTORY = [
        'cmake-build-debug',
        'cmake-build-release',
        'build',
        'Build',
        'build-rpi-zero',
        'Build-rpi-zero'
        ]

def IsSourceFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in C_SOURCE_EXTENSIONS + CPP_SOURCE_EXTENSIONS + CU_SOURCE_EXTENSIONS

def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS

def GetCompilationInfoForFile(database, filename):
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in C_SOURCE_EXTENSIONS + CPP_SOURCE_EXTENSIONS + CU_SOURCE_EXTENSIONS:
            # Get info from the source files by replacing the extension.
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                compilation_info = database.GetCompilationInfoForFile(replacement_file)
                if compilation_info.compiler_flags_:
                    return compilation_info
            # If that wasn't successful, try replacing possible header directory with possible source directories.
            for header_dir in HEADER_DIRECTORIES:
                for source_dir in SOURCE_DIRECTORIES:
                    src_file = replacement_file.replace(header_dir, source_dir)
                    if os.path.exists(src_file):
                        compilation_info = database.GetCompilationInfoForFile(src_file)
                        if compilation_info.compiler_flags_:
                            return compilation_info
        return None
    return database.GetCompilationInfoForFile(filename)

def FindNearest(path, target, build_folder=None):
    candidate = os.path.join(path, target)
    if(os.path.isfile(candidate) or os.path.isdir(candidate)):
        logging.info("Found nearest " + target + " at " + candidate)
        return candidate

    parent = os.path.dirname(os.path.abspath(path));
    if(parent == path):
        return None # could no find compile_commands.json
        # raise RuntimeError("Could not find " + target);

    if(build_folder):
        candidate = os.path.join(parent, build_folder, target)
        if(os.path.isfile(candidate) or os.path.isdir(candidate)):
            logging.info("Found nearest " + target + " in build folder at " + candidate)
            return candidate

    return FindNearest(parent, target, build_folder)

def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[ len(path_flag): ]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        clang_complete_flags = open(clang_complete_path, 'r').read().splitlines()
        return clang_complete_flags
    except:
        return None

def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = []
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags = flags + ["-I" + real_path]
        return flags
    except:
        return None

def FlagsForCompilationDatabase(root, filename):
    try:
        import ycm_core
        # Last argument of next function is the name of the build folder for
        # out of source projects
        found = False
        for build in BUILD_DIRECTORY:
            compilation_db_path = FindNearest(root, 'compile_commands.json', build)
            if not compilation_db_path:
                continue
            compilation_db_dir = os.path.dirname(compilation_db_path)
            compilation_db =  ycm_core.CompilationDatabase(compilation_db_dir)
            if not compilation_db:
              logging.info("Compilation database file found but unable to load")
              continue
            compilation_info = GetCompilationInfoForFile(compilation_db, filename)
            if not compilation_info:
                logging.info("No compilation info for " + filename + " in compilation database")
                continue
            logging.info("Found compilation datafile in " + compilation_db_dir)
            return MakeRelativePathsInFlagsAbsolute(
                    compilation_info.compiler_flags_,
                    compilation_info.compiler_working_dir_)
        assert(found == False) # should be false
        return None
    except Exception as e:
        logging.debug("value of e is {}".format(str(e)))
        logging.debug("Inside except of FlagsForCompilationDatabase in .ycm_extra_conf.py")
        return None

def FlagsForFile(filename):
    root = os.path.realpath(filename);
    compilation_db_flags = FlagsForCompilationDatabase(root, filename)
    logging.debug("compilation_db_flags is set to {}".format(compilation_db_flags))
    if compilation_db_flags:
        logging.debug("compilation_db_flags is setting final_flags")
        final_flags = compilation_db_flags
        logging.debug("type of final_flags is set to " + type(final_flags).__name__)
    else:
        logging.debug("IsSourceFile({}) = {}".format(filename, IsSourceFile(filename)))
        if IsSourceFile(filename):
            extension = os.path.splitext(filename)[1]
            if extension in C_SOURCE_EXTENSIONS:
                final_flags = C_BASE_FLAGS
            elif extension in CU_SOURCE_EXTENSIONS:
                final_flags = CU_BASE_FLAGS
            else:
                final_flags = CPP_BASE_FLAGS

        clang_flags = FlagsForClangComplete(root)
        if clang_flags:
            final_flags = final_flags + clang_flags
        include_flags = FlagsForInclude(root)
        if include_flags:
            final_flags = final_flags + include_flags
        logging.info("flags: {}".format(final_flags))
    return {
            'flags': final_flags,
            'do_cache': True
            }


def Settings( **kwargs ):
    if kwargs['language'] == 'rust':
        return {
                'ls': {
                    'rust': {
                        'all_features': True,
                        'racer_completion': True,
                        }
                    }
                }
    elif kwargs['language'] == 'python':
        return {
                'interpreter_path': 'python3'
                }
    import ycm_core
    filename = kwargs['filename']
    return FlagsForFile(filename)
