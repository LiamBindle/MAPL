module pFIO_AbstractSocketMod
   implicit none
   private

   public :: AbstractSocket

   type, abstract :: AbstractPort
   end type AbstractPort

   type, abstract :: AbstractSocket
   contains
      procedure (receive), deferred :: receive
      procedure (send), deferred :: send

      procedure (put), deferred :: put
      procedure (get), deferred :: get
      procedure (to_string), deferred :: to_string
      procedure :: has_message =>dummy_probe
   end type AbstractSocket

   abstract interface


      function receive(this) result(message)
         use pFIO_AbstractMessageMod
         import AbstractSocket
         implicit none
         class (AbstractMessage), pointer :: message
         class (AbstractSocket), intent(inout) :: this
      end function receive


      subroutine send(this, message)
         use pFIO_AbstractMessageMod
         import AbstractSocket
         implicit none
         class (AbstractSocket), intent(inout) :: this
         class (AbstractMessage), intent(in) :: message
      end subroutine send


      function put(this, request_id, local_reference) result(handle)
         use pFIO_AbstractDataReferenceMod
         use pFIO_AbstractRequestHandleMod
         import AbstractSocket
         class (AbstractRequestHandle), allocatable :: handle
         class (AbstractSocket), intent(inout) :: this
         integer, intent(in) :: request_id
         class (AbstractDataReference), intent(in) :: local_reference
      end function put

      
      function get(this, request_id, local_reference) result(handle)
         use pFIO_AbstractDataReferenceMod
         use pFIO_AbstractRequestHandleMod
         import AbstractSocket
         class (AbstractRequestHandle), allocatable :: handle
         class (AbstractSocket), intent(inout) :: this
         integer, intent(in) :: request_id
         class (AbstractDataReference), intent(in) :: local_reference
      end function get


      function to_string(this) result(string)
         import AbstractSocket
         class (AbstractSocket), intent(in) :: this
         character(len=:), allocatable :: string
      end function to_string

   end interface
contains

   function dummy_probe(this) result(has)
      class(AbstractSocket), intent(inout) :: this
      logical :: has
      has = .true.
   end function 

end module pFIO_AbstractSocketMod

