class DeletedUser < User
  default_scope { only_deleted }
end
