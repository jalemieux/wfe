#generic exception
class Wfe::Exception < Exception
end
class Wfe::WorkflowLocked < Exception
end
class Wfe::WorkflowHalted < Exception
end
# Raised when the workflow is in error state (one of its step is not pending or completed)
class Wfe::ErrorState < Exception
end
class Wfe::StepError < Exception
end
class Wfe::WorkflowMIA < Exception
end
