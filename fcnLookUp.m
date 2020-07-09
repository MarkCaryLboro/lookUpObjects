classdef fcnLookUp < lookUp
    % 1-dimensional look-up table class
    properties
        Xname       string = "x"                                            % Input variable name
        Zname       string = "z"                                            % Response variable name
    end
    
    properties ( SetAccess = protected )
        A           double      = (0)                                       % Lower Bound for Breakpoints
        B           double      = (1)                                       % Upper Bound for Breakpoints
    end % protected properties
    
    properties ( Access = protected )
        BP          cell                                                    % Breakpoint locations
    end % protected properties
    
    properties ( Constant = true )
        Type = "Function"
    end % constant properties
    
    properties ( SetAccess = immutable )
        Nbp     int8                                                        % Number of breakpoints
        Name    string                                                      % Name of lookup
    end % Immutable & abstract properties
    
    properties ( SetAccess = protected, Dependent = true )
        BPS     double                                                      % break point locations
    end
    
    methods
        function obj = fcnLookUp( Name, Nbp )
            %--------------------------------------------------------------
            % Design a single input lookup table object
            %
            % obj = fcnLookUp( Name, Nbp );
            %
            % Input Arguments:
            %
            % Name      --> Name of 1-D lookup table (string).
            % Nbp       --> Number of breakpoints
            %--------------------------------------------------------------
            obj.Name = Name;
            if isnumeric( Nbp ) && ( Nbp >= 2 )
                obj.Nbp = int8( Nbp );
            else
                error('Number of breakpoints must be greater than or equal to 2');
            end
            obj.Z = zeros( obj.Nbp, 1 );
            obj.BP = obj.linDistBps();
        end
        
        function obj = setResponse( obj, Z )
            %--------------------------------------------------------------
            % Set the response data if required
            %
            % obj = obj.setResponse( Z );
            %
            % Input Arguments:
            %
            % Z     --> Response data.
            %--------------------------------------------------------------
            if ( nargin < 2 ) || ( numel( Z ) ~= obj.Nbp )
                %----------------------------------------------------------
                % Throw an error
                %----------------------------------------------------------
                error('Response vector must have %2.0d elements', obj.Nbp);
            else
                %----------------------------------------------------------
                % Assign the data
                %----------------------------------------------------------
                obj.Z = Z( : );
            end
        end
        
        function obj = setBreakPoints( obj, BPs )
            %--------------------------------------------------------------
            % Manually define the breakpoint locations
            %
            % obj = obj.setBreakPoints( BPs );
            %
            % Input Arguments:
            %
            % BPs   --> Breakpoint location data. If empty, the bps are
            %           set linearly in the interval [obj.A, obj.B]. If BPs
            %           is a vector with obj.Nbp elements then the bps are
            %           set to this. obj.A and obj.B are set to min( BPs )
            %           & max( BPs ) in this case.
            %--------------------------------------------------------------
            if ( nargin < 2 ) || isempty( BPs )
                %----------------------------------------------------------
                % Linearly distribute breakpoints
                %----------------------------------------------------------
                obj.BPs = obj.linDistBps();
            elseif numel( BPs ) == obj.Nbp
                %----------------------------------------------------------
                % Assign breakpoints and reset bounds
                %----------------------------------------------------------
                obj.BPs = BPs(:);
                obj = setBounds( min( BPs ), max( BPs ) );
            end
        end
        
        function obj = setBounds( obj, A1, B1 )
            %--------------------------------------------------------------
            % Set the upper & lover bounds for the breakpoints
            %
            % obj = obj.setBounds( A, B );
            %
            % Input Arguments:
            %
            % A     --> Lower bound for breakpoints {0};
            % B     --> Upper bound for breakpoints {1};
            %--------------------------------------------------------------
            if ( nargin < 2 ) || isempty( A1 )
                A1 = 0;                                                     % Apply default
            end
            if ( nargin < 3 ) || isempty( B1 )
                B1 = 1;                                                     % Apply default
            end
            if ( A1 ~= B1 )
                obj.A = min( [A1, B1] );                                    % Assign lower bound
                obj.B = max( [A1, B1] );                                    % Assign upper bound
            else
                error('Upper and Lower breakpoint bounds must be distinct');
            end
        end
        
        function Z = interp( obj, X )
            %--------------------------------------------------------------
            % Linearly interpolate data with input clipped to lay within
            % range
            %
            % Z = obj.interp( X );
            %
            % Input Arguments:
            %
            % X     --> Data input vector.
            %--------------------------------------------------------------
            X = obj.clipData( X( : ) );
            In = obj.X{:};
            Z = interp1( In, obj.Z, X, 'linear' );                          % Linearly interpolate user supplied data
        end
    end % ordinary and constructor methods
    
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
    end
    
    methods       
        function obj = set.A( obj, Value )
            % Set lower bound for breakpoints
            if isnumeric( Value ) && isreal( Value ) && ( numel( Value ) == 1 ) 
                obj.A = Value;
            else
                error('Lower BP Bound must be a numeric scalar');
            end
        end
        
        function obj = set.B( obj, Value )
            % Set upper bound for breakpoints
            if isnumeric( Value ) && isreal( Value ) && ( numel( Value ) == 1 )
                obj.B = Value;
            else
                error('Lower BP Bound must be a numeric scalar');
            end
        end
        
        function B = get.BPS( obj )
            % Retrieve break point locations as a double
            B = [obj.BP{:}];
        end
    end % Get/Set methods
    
    methods ( Access = private )
        function Xbp = linDistBps( obj )
            %--------------------------------------------------------------
            % Linearly distribute breakpoints in interval [A, B]
            %--------------------------------------------------------------
            Xbp = {linspace( obj.A, obj.B, obj.Nbp ).'};
        end
    end
end