function passCheck = checkOpenSTREAMVersion()
%CHECKOPENSTREAMVERSION Check whether the installed OpenSTREAM version satisfies
%                       the required dependency version.
%
%   PASSCHECK = checkOpenSTREAMVersion() checks whether OpenSTREAM is available
%   and whether its installed version satisfies the version requirement
%   specified by OPENSTREAMVERSIONREQUIREMENT.
%
%   PASSCHECK is true if the dependency requirement is satisfied and false
%   otherwise.
%
%   Version requirements use pip-style comparison operators, including:
%       ==    Equal to
%       !=    Not equal to
%       ~=    Greater than or equal to but less than next major release
%       >=    Greater than or equal to
%       <=    Less than or equal to
%       >     Greater than
%       <     Less than
%
%   Multiple requirements may be separated by commas. All requirements
%   must be satisfied for PASSCHECK to be true.
%
%   Example:
%       PASSCHECK = CHECKDEPENDENCY()
%
%   See also OPENSTREAMVERSION

openstreamVersionRequirement = "~=2026.0";

passCheck = true;
if isempty(which('openstreamVersion'))
    passCheck = false;
    warning("OpenSTREAMDatabase:OpenSTREAMVersionMismatch", ...
        "OpenSTREAM version %s required, none found", ...
        openstreamVersionRequirement);
    return
end

% openstream version
[opsver_str, ops_ver_maj, ops_ver_min, ops_ver_update] = openstreamVersion();
opsVer = [ops_ver_maj, ops_ver_min, ops_ver_update];

% Split requirement by comma

pattern = '(?<operator>==|!=|<=|~=|>=|<|>)[ ]*(?<version>\d+(?:\.\d+)*)';

reqs = regexp(openstreamVersionRequirement, pattern, 'names');

for k = 1:numel(reqs)

    req = reqs(k);

    % Parse requirement 
    reqVer = str2double(strsplit(req.version, '.'));
    
    % Compare two versions
    res = compareVersions(opsVer, reqVer);

    % Check operator
    switch req.operator
        case "=="
            if res ~= 0, passCheck = false; end
        case "!="
            if res == 0, passCheck = false; end
        case "~="
            if res < 0, passCheck = false; end
            if compareVersions(opsVer, [reqVer(1)+1, 0, 0]) >= 0
                passCheck = false;
            end
        case ">="
            if res < 0, passCheck = false; end
        case "<="
            if res > 0, passCheck = false; end
        case "<"
            if res >= 0, passCheck = false; end
        case ">"
            if res <= 0, passCheck = false; end
        otherwise
            passCheck = false;
    end

end

% Provide warning
if ~passCheck
    warning("OpenSTREAMDatabase:OpenSTREAMVersionMismatch", ...
        "OpenSTREAM version %s required, %s found", ...
        openstreamVersionRequirement, ...
        opsver_str);
end

    function res = compareVersions(v1, v2)

        v1_length = numel(v1);
        v2_length = numel(v2);
        res = 0;

        max_length = max(v1_length, v2_length);

        for i=1:max_length
            num1 = 0;
            num2 = 0;
            if i <= v1_length, num1 = v1(i); end
            if i <= v2_length, num2 = v2(i); end

            % Compare
            if num1 < num2
                res = -1;
                return
            elseif num1 > num2
                res = 1;
                return
            end
        end

    end

end