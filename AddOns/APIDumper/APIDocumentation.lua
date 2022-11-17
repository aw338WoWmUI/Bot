local addOnName, AddOn = ...

AddOn.APIDocumentation = {
  ['GMR.MeshTo'] = {
    parameters = {
      {
        name = 'x',
        type = 'number'
      },
      {
        name = 'y',
        type = 'number'
      },
      {
        name = 'z',
        type = 'number'
      }
    }
  },
  ['GMR.DefineQuest'] = {
    parameters = {
      {
        name = 'factionFor',
        type = 'string | table',
        description = "'Alliance', 'Horde' or {'Alliance', 'Horde'}"
      },
      {
        name = 'classesFor',
        type = 'table | nil',
        description = 'A list of classes that the quest is for. When `nil` is passed, then the quest is considered to be for all classes. Valid values for the classes seem to be the keys of `GMR.Variables.Specializations`.'
      },
      {
        name = 'questID',
        type = 'number'
      },
      {
        name = 'questName',
        type = 'string'
      },
      {
        name = 'gmrQuestType',
        type = 'string',
        description = 'Possible values include `Custom`, `MassPickUp` and `Grinding`.'
      }
      -- There are more parameters
    }
  },
  ['GMR.GetPositionFromPosition'] = {
    description = 'Calculates a position based on another position, a length, and two angles.',
    parameters = {
      {
        name = 'x',
        type = 'number'
      },
      {
        name = 'y',
        type = 'number'
      },
      {
        name = 'z',
        type = 'number'
      },
      {
        name = 'length',
        type = 'number'
      },
      {
        name = 'angle1',
        type = 'number',
        description = 'In radian.'
      },
      {
        name = 'angle2',
        type = 'number',
        description = 'In radian.'
      }
    }
  }
}
