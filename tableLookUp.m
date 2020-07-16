classdef tableLookUp < lookUp
    % 2-dimensional look-up table class
    properties
        Xname   string       = [ "x", "y" ]                                 % name of input(s)
        Zname   string       = "z"                                          % response name
    end
    
    properties ( SetAccess = immutable )
        Nbp     int8                                                        % Number of breakpoints
        Name    string                                                      % Name of lookup
    end % Immutable & abstract properties    
    
    properties ( SetAccess = protected )
        A       double = [ 0, 0 ]                                           % Lower Bound for Breakpoints
        B       double = [ 1, 1 ]                                           % Upper Bound for Breakpoints
    end % Protected & abstract properties    
    
    properties ( Access = protected )
        BP          cell                                                    % Breakpoint locations
    end % protected properties
    
    properties ( Dependent = true ) 
        CBP     double                                                      % Column breakpoints
        RBP     double                                                      % Row breakpoints
    end % dependent properties
    
    properties ( Access = private, Dependent = true )
        Nbp_   double                                                       % Table size (R, C)
    end % Private and dependent properties
    
    properties ( Constant = true )
        Type = "Table"
    end % constant properties
    
    properties ( Access = private, Constant = true )
        R      int8 = 2                                                     % Index for row data
        C      int8 = 1                                                     % Index for column data
    end
    
    methods 
        function obj = tableLookUp( Name, Nbp )
            %--------------------------------------------------------------
            % Design a 2-dimensional lookup table object
            %
            % obj = tableLookUp( Name, Nbp );
            %
            % Input Arguments:
            %
            % Name      --> Name of 1-D lookup table (string).
            % Nbp       --> Number of breakpoints int8(1,2). First element
            %               is the number of columns, second the number of
            %               rows.
            %--------------------------------------------------------------        
            obj.Name = Name;
            if all( isnumeric( Nbp ) ) && all( ( Nbp >= 2 ) )
                obj.Nbp = int8( reshape( Nbp, 1, 2 ) );
            else
                error('Number of breakpoints must be greater than or equal to 2');
            end
            obj.Z = zeros( obj.Nbp_ );
            obj.BP = obj.linDistBps();
        end
        
        function Out = interp( obj, In )                                           
            %--------------------------------------------------------------
            % Linearly interpolate data with input clipped to lay within
            % range
            %
            % Z = obj.interp( X );
            %
            % Input Arguments:
            %
            % X     --> (Nx2) data input vector.
            %--------------------------------------------------------------
            if ( size( In, 2 ) ~= 2 )
                error('Input data vector must have 2 columns');
            end
            [ X, Y] = meshgrid( obj.BP{ 1 }, obj.BP{ 2 } );
            In = obj.clipData( In );
            Out = interp2( X, Y, obj.Z, In( :, 1 ), In( :, 2 ), 'linear' );
        end
        
        function obj = setBounds( obj, A1, B1 )
            %--------------------------------------------------------------
            % Set the upper & lover bounds for the breakpoints
            %
            % obj = obj.setBounds( A, B );
            %
            % Input Arguments:
            %
            % A     --> Lower bound for breakpoints: double(1,2), {[0,0]}
            % B     --> Upper bound for breakpoints: double(1,2), {[1,1]}
            %--------------------------------------------------------------        
            if ( nargin < 2 ) || isempty( A1 )
                A1 = [0, 0];                                                % Apply default
            end
            if ( nargin < 3 ) || isempty( B1 )
                B1 = [1, 1];                                                % Apply default
            end
            if ( numel( A1 ) == 2 ) && ( numel( B1 ) == 2 )
                %----------------------------------------------------------
                % Assign bounds
                %----------------------------------------------------------
                A1 = reshape( A1, 1, 2 );
                B1 = reshape( B1, 1, 2 );
                if any( A1 == B1 )
                    error('Upper and Lower breakpoint bounds must be distinct');
                else
                    obj.A = min( [A1; B1] );
                    obj.B = max( [A1; B1] );
                end
            else
                error('Upper and lower break point bounds must have exactly 2 elements');
            end
        end
        
        function obj = setBreakPoints( obj, X )
            %--------------------------------------------------------------
            % Manually define the breakpoint locations
            %
            % obj = obj.setBreakPoints( BPs );
            %
            % Input Arguments:
            %
            % BPs   --> (1x2) cell array of breakpoint locations:
            %           {[Cols], [Rows]}
            %--------------------------------------------------------------
            if ( nargin < 2 ) || isempty( X )
                %----------------------------------------------------------
                % Linearly distribute breakpoints
                %----------------------------------------------------------
                obj.BP = obj.linDistBps();
            elseif ~iscell( X ) || ( numel( X ) ~= 2 )
                error('Breakpoints argument must be a 1x2 cell array');
            else
                %----------------------------------------------------------
                % Assign breakpoints and reset bounds
                %----------------------------------------------------------
                for Q = 1:2
                    if ( numel( X{ Q } ) == obj.Nbp( Q )  )
                        %--------------------------------------------------
                        % Assign breakpoints for this dimension
                        %--------------------------------------------------
                        if ( Q == 1 )
                            %----------------------------------------------
                            % Columns
                            %----------------------------------------------
                            M = 1;
                            N = obj.Nbp( Q );
                        else
                            %----------------------------------------------
                            % Rows
                            %----------------------------------------------
                            M = obj.Nbp( Q );
                            N = 1;
                        end
                        obj.BP( Q ) = { sort( reshape( X{ Q }, M, N ) ) };
                        %--------------------------------------------------
                        % Reset the data bounds
                        %--------------------------------------------------
                        obj.A( Q ) = min( X{ Q } );
                        obj.B( Q ) = max( X{ Q } );
                    else
                        error('Breakpoint vectors supplied not of correct dimension'); 
                    end
                end
            end
        end
        
        function obj = setResponse( obj, Z )
            %--------------------------------------------------------------
            % Set the response data if required
            %
            % obj = obj.setResponse( Z );
            %
            % Input Arguments:
            %
            % Z     --> Response data, must be "x"-columns by "y"-rows.
            %--------------------------------------------------------------
            if ( nargin < 2 ) || any( fliplr( size( Z ) ) ~= obj.Nbp )
                %----------------------------------------------------------
                % Throw an error
                %----------------------------------------------------------
                error('Response data must have %3.0d rows and %3.0d columns',...
                    obj.Nbp_( 1 ), obj.Nbp_( 2 ) );
            else
                %----------------------------------------------------------
                % Assign the data
                %----------------------------------------------------------
                obj.Z = Z;
            end
        end
        
        function plot( obj, Ax )
            %--------------------------------------------------------------
            % Generate a surface mesh plot for the table
            %
            % obj.plot();      % plot to a new figure { default }
            % obj.plot( Ax );  % plot on the axes indicated
            %
            % Input Arguments:
            %
            % Ax    --> Axes handle
            %--------------------------------------------------------------
            if ( nargin < 2 ) || ~ishandle( Ax ) || ~strcmpi( 'axes', Ax.Type )
                %----------------------------------------------------------
                % Create a new figure and Axes object
                %----------------------------------------------------------
                Fig = figure;
                Ax = axes( 'Parent', Fig );
            end
            axes( Ax );
            [ X, Y ] = meshgrid( obj.CBP, obj.RBP );
            mesh( X, Y, obj.Z );
            grid on;
            xlabel( obj.Xname( 1 ), 'FontSize', 14, 'Interpreter', 'None' );
            ylabel( obj.Xname( 2 ), 'FontSize', 14, 'Interpreter', 'None' );
            zlabel( obj.Zname, 'FontSize', 14 );
            title( obj.Name, 'FontSize', 14, 'Interpreter', 'None' );
        end
    end % ordinary abstract method signatures
    
    methods
        function R = get.RBP( obj )
            % Return column breakpoint vector
            R = obj.BP{ 2 };
        end
        
        function C = get.CBP( obj )
            % Return column breakpoint vector
            C = obj.BP{ 1 };
        end
        
        function obj = set.Xname( obj, Value )
            % Set the Xname property if it has the correct dimensions
            if numel( Value ) == 2
                Value = reshape( Value, 1, 2 );
                obj.Xname = Value;
            else
                warning('Property "Xname" not set');
            end
        end
        
        function Bp = get.Nbp_( obj )
            % Return #bp as a double(1,2), where Bp = [#rows, #cols]
            Bp = double( fliplr( obj.Nbp ) );
        end
    end % set/get methods
    
    methods ( Access = protected )
        function X = clipData( obj, X )
            %--------------------------------------------------------------
            % Clip the input data to the set range
            %
            % Xc = obj.clipData( X );
            %--------------------------------------------------------------
            [ Lo, Hi ] = obj.dataOutofBnds( X );
            X( Lo ) = obj.A;
            X( Hi ) = obj.B;
        end
    end % protected methods
    
    methods ( Access = private )
        function Xbp = linDistBps( obj )
            %--------------------------------------------------------------
            % Linearly distribute breakpoints in interval [A, B]
            %--------------------------------------------------------------
            Xbp = cell( 1, 2 );                                             % Define storage
            for Q = 1:2
                Xlo = obj.A( Q );
                Xhi = obj.B( Q );
                N = obj.Nbp( Q );
                if ( Q ~= 1 )
                    Xbp{ Q } = linspace( Xlo, Xhi, N ).';                   % Make a column vector for rows
                else
                    Xbp{ Q } = linspace( Xlo, Xhi, N );                     % Make a line vector for columns
                end
            end
        end
    end % private & helper methods    
end