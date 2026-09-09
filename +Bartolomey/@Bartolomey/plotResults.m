function plotResults(data, TestName, xparam)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here

arguments
    data
    TestName
    xparam   (1,:) char {mustBeMember(xparam,{'X','Z'})} = 'Z'
end



figure('name',TestName);

for i = 1:length(data)

    entry = data(i).entryData;
    z   = data(i).results.Z;

    hasQuality = ~isempty(entry.Quality) && ~all(ismissing(entry.Quality));
    hasElevation = ~isempty(entry.Elevation) && ~all(ismissing(entry.Elevation));

    if isprop(data(i).results,'mixture')
        mix = data(i).results.mixture;
    elseif isprop(data(i).results,'liquid')
        mix = data(i).results.liquid.mix;
    end

    ax(i) = nexttile; hold on; grid on; title(['TestID ' num2str(entry.TestID)])
    switch xparam
        case 'X'
            plot(mix.XEQ,mix.VF,'.-','displayName','Predicted')
            if hasQuality
                plot(entry.Quality,entry.VoidFraction,'k*','displayName','Measured')
            elseif hasElevation
                plot(interp1(mix.Z,mix.XEQ,entry.Elevation),entry.VoidFraction,'k*','displayName','Measured')
            else
                warning('OpenSTREAMDatabase:Bartolomey:MissingCoordinates', 'TestID %g has neither Quality nor Elevation data.', entry.TestID);
            end
            xlabel('Equilibrium quality [-]')

        case 'Z'
            plot(z,mix.VF,'.-','displayName','Predicted')
            if hasQuality
                plot(interp1(mix.XEQ,z,entry.Quality),entry.VoidFraction,'k*','displayName','Measured')
            elseif hasElevation
                plot(entry.Elevation,entry.VoidFraction,'k*','displayName','Measured')
            else
                warning('OpenSTREAMDatabase:Bartolomey:MissingCoordinates', 'TestID %g has neither Quality nor Elevation data.', entry.TestID);
            end
            xlabel('Elevation [-]')
    end
    ylabel('Void fraction [-]'); ylim([0 1]);
    legend('show','location','northWest')
    set(gca,'fontSize',14)
    linkaxes(ax)

end

end
