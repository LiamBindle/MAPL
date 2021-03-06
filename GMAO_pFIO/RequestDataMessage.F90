module pFIO_RequestDataMessageMod
   use pFIO_AbstractMessageMod
   use pFIO_UtilitiesMod
   use pFIO_ArrayReferenceMod
   use pFIO_KeywordEnforcerMod
   implicit none
   private

   public :: RequestDataMessage

   type, extends(AbstractMessage) :: RequestDataMessage
      integer :: request_id
      integer :: collection_id
      character(len=:), allocatable :: file_name
      character(len=:), allocatable :: var_name
      integer :: type_kind
      integer, allocatable :: start(:)
      integer, allocatable :: count(:)
      type (ArrayReference) :: data_reference
   contains
      procedure, nopass :: get_type_id
      procedure :: get_length
      procedure :: serialize
      procedure :: deserialize
   end type RequestDataMessage

   interface RequestDataMessage
      module procedure new_RequestDataMessage
   end interface RequestDataMessage

contains


   function new_RequestDataMessage( &
        & request_id, collection_id, file_name, var_name, &
        & data_reference, unusable, start) result(message)
      type (RequestDataMessage) :: message
      integer, intent(in) :: request_id
      integer, intent(in) :: collection_id
      character(len=*), intent(in) :: file_name
      character(len=*), intent(in) :: var_name
      type (ArrayReference), intent(in) :: data_reference
      class (KeywordEnforcer), optional, intent(in) :: unusable
      integer, optional, intent(in) :: start(:)

      integer :: i

      message%request_id = request_id
      message%collection_id = collection_id
      message%file_name = file_name
      message%var_name = var_name
      message%type_kind= data_reference%type_kind
      message%data_reference = data_reference
      message%count = data_reference%shape

      if (present(start)) then
         message%start = start
      else
         message%start = [(1,i=1,size(data_reference%shape))]
      end if
      
      !if(size(message%start) /= size(message%count) ) stop "start and count not match"
      
   end function new_RequestDataMessage
 

   integer function get_type_id() result(type_id)
      type_id = RequestData_ID
   end function get_type_id

   integer function get_length(this) result(length)
      class (RequestDataMessage), intent(in) :: this

      length = &
           & serialize_buffer_length(this%request_id) + &
           & serialize_buffer_length(this%collection_id) + &
           & serialize_buffer_length(this%file_name) + &
           & serialize_buffer_length(this%var_name) + &
           & serialize_buffer_length(this%type_kind) + &
           & serialize_buffer_length(this%start) + &
           & serialize_buffer_length(this%count) + &
           & this%data_reference%get_length()
   end function get_length

   subroutine serialize(this, buffer)
      class (RequestDataMessage), intent(in) :: this
      integer, intent(inout) :: buffer(:) ! no-op

      integer, allocatable :: data_buf(:)
      
      call this%data_reference%serialize(data_buf)

      buffer = [ &
           & serialize_intrinsic(this%request_id), &
           & serialize_intrinsic(this%collection_id), &
           & serialize_intrinsic(this%file_name), &
           & serialize_intrinsic(this%var_name), &
           & serialize_intrinsic(this%type_kind), &
           & serialize_intrinsic(this%start), &
           & serialize_intrinsic(this%count), &
           & data_buf]

   end subroutine serialize

   subroutine deserialize(this, buffer)
      class (RequestDataMessage), intent(inout) :: this
      integer, intent(in) :: buffer(:)

      integer :: n

      n = 1
      call deserialize_intrinsic(buffer(n:), this%request_id)
      n = n + serialize_buffer_length(this%request_id)
      call deserialize_intrinsic(buffer(n:), this%collection_id)
      n = n + serialize_buffer_length(this%collection_id)
      call deserialize_intrinsic(buffer(n:), this%file_name)
      n = n + serialize_buffer_length(this%file_name)
      call deserialize_intrinsic(buffer(n:),this%var_name)
      n = n + serialize_buffer_length(this%var_name)
      call deserialize_intrinsic(buffer(n:), this%type_kind)
      n = n + serialize_buffer_length(this%type_kind)
      call deserialize_intrinsic(buffer(n:), this%start)
      n = n + serialize_buffer_length(this%start)
      call deserialize_intrinsic(buffer(n:), this%count)
      n = n + serialize_buffer_length(this%count)
      call this%data_reference%deserialize(buffer(n:))
   end subroutine deserialize
   
end module pFIO_RequestDataMessageMod

