esma_set_this ()

add_definitions(-DMAPL)
add_definitions(-DDO_COMMAS)
add_definitions(-DTWO_SIDED_COMM)
add_definitions(-DHAVE_SHMEM)

if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
  if(CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 20)
    if(CMAKE_Fortran_COMPILER_VERSION VERSION_GREATER 17)
      add_definitions(-D__ifort_18)
    endif()
  endif()
endif()

set (srcs

  # CFIO Files
  KeywordEnforcer.F90
  Throw.F90
  pFIO_Constants.F90
  Attribute.F90
  Variable.F90
  CoordinateVariable.F90
  
  FileMetadata.F90
  NetCDF4_FileFormatter.F90
  pFIO_Utilities.F90
  pFIO.F90

  AbstractMessage.F90
  MessageVisitor.F90
  TerminateMessage.F90
  DoneMessage.F90
  DummyMessage.F90
  AddCollectionMessage.F90
  CollectionIdMessage.F90
  RequestIdMessage.F90
  RequestDataMessage.F90
  WaitRequestDataMessage.F90
  CollectiveRequestDataMessage.F90
  ProtocolParser.F90

  MpiMutex.F90
  AbstractDirectoryService.F90
  SimpleDirectoryService.F90
  DirectoryService.F90
  AbstractSocket.F90
  AbstractSocketVector.F90
  MpiSocket.F90
  SimpleSocket.F90
  IntegerSocketMap.F90

  AbstractServer.F90
  MpiServer.F90
  OpenMPServer.F90
  SimpleServer.F90
  ServerThread.F90
  ServerThreadVector.F90
  BaseThread.F90
  ClientThread.F90
  ExtDataCollection.F90

  IntegerMessageMap.F90
  IntegerRequestMap.F90
  MessageQueue.F90
  AbstractDataReference.F90
  ArrayReference.F90
  MemReference.F90
  ShmemReference.F90
  AbstractRequestHandle.F90
  IntegerIntegerMap.F90
  StringIntegerMap.F90
  StringVector.F90
  )

esma_add_library (${this} SRCS ${srcs})
target_link_libraries (${this} gftl ${NETCDF_LIBRARIES})

target_compile_options (${this} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:${OpenMP_Fortran_FLAGS}>)
set_target_properties (${this} PROPERTIES Fortran_MODULE_DIRECTORY ${include_${this}})
target_link_libraries (${this} ${MPI_Fortran_LIBRARIES} ${OpenMP_Fortran_LIBRARIES})
# Kludge for OSX security and DYLD_LIBRARY_PATH ...
foreach(dir ${OSX_EXTRA_LIBRARY_PATH})
  target_link_libraries(${this} "-Xlinker -rpath -Xlinker ${dir}")
endforeach()


if (NOT CMAKE_Fortran_COMPILER_ID MATCHES GNU)
  # GFortran gives bizarre LD error for the following targets.
  ecbuild_add_executable (
    TARGET pfio_server_demo.x
    SOURCES pfio_server_demo.F90
    LIBS ${this} ${ESMF_LIBRARIES} ${OpenMP_Fortran_LIBRARIES})
  set_target_properties (pfio_server_demo.x PROPERTIES Fortran_MODULE_DIRECTORY ${include_${this}})
  set_target_properties(pfio_server_demo.x PROPERTIES LINK_FLAGS "${OpenMP_Fortran_FLAGS}")
    
  ecbuild_add_executable (
    TARGET pfio_collective_demo.x
    SOURCES pfio_collective_demo.F90
    LIBS ${this} ${ESMF_LIBRARIES} ${OpenMP_Fortran_LIBRARIES})
  set_target_properties (pfio_collective_demo.x PROPERTIES Fortran_MODULE_DIRECTORY ${include_${this}})
  set_target_properties(pfio_collective_demo.x PROPERTIES LINK_FLAGS "${OpenMP_Fortran_FLAGS}")
endif ()

#--------------------
include_directories (${INC_ESMF})
include_directories (${INC_gFTL})
include_directories (${INC_FLAP})
include_directories (${INC_NETCDF})

#--------------------
# Copy include files that are used by other libraries.
# We could leave these in the source directory, and just broaden the search path
# in the other libaries, but this make it explicit which aspects are externally
# used.

file (COPY unused_dummy.H DESTINATION ${include_${this}})

# Users guide 
if (LATEX_FOUND)
#  add_subdirectory (TeX)
endif ()


# Unit testing
if (PFUNIT)
  add_subdirectory(tests)
endif ()

