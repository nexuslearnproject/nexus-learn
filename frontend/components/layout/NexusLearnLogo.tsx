interface NexusLearnLogoProps {
  className?: string;
  iconOnly?: boolean;
}

export function NexusLearnLogo({ className = "", iconOnly = false }: NexusLearnLogoProps) {
  if (iconOnly) {
    return (
      <svg 
        width="40" 
        height="40" 
        viewBox="0 0 40 40" 
        fill="none" 
        xmlns="http://www.w3.org/2000/svg"
        className={className}
      >
        {/* Outer hexagon */}
        <path 
          d="M20 2L34.6410 10.5V27.5L20 36L5.35898 27.5V10.5L20 2Z" 
          stroke="#2563EB" 
          strokeWidth="2.5" 
          fill="none"
        />
        
        {/* Inner connecting lines forming "N" shape */}
        <path 
          d="M13 14L13 26M13 14L27 26M27 26L27 14" 
          stroke="#2563EB" 
          strokeWidth="2.5" 
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        
        {/* Connection dots */}
        <circle cx="13" cy="14" r="2" fill="#2563EB"/>
        <circle cx="13" cy="26" r="2" fill="#2563EB"/>
        <circle cx="27" cy="14" r="2" fill="#2563EB"/>
        <circle cx="27" cy="26" r="2" fill="#2563EB"/>
        <circle cx="20" cy="20" r="2" fill="#7C3AED"/>
      </svg>
    );
  }

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <svg 
        width="40" 
        height="40" 
        viewBox="0 0 40 40" 
        fill="none" 
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Outer hexagon */}
        <path 
          d="M20 2L34.6410 10.5V27.5L20 36L5.35898 27.5V10.5L20 2Z" 
          stroke="#2563EB" 
          strokeWidth="2.5" 
          fill="none"
        />
        
        {/* Inner connecting lines forming "N" shape */}
        <path 
          d="M13 14L13 26M13 14L27 26M27 26L27 14" 
          stroke="#2563EB" 
          strokeWidth="2.5" 
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        
        {/* Connection dots */}
        <circle cx="13" cy="14" r="2" fill="#2563EB"/>
        <circle cx="13" cy="26" r="2" fill="#2563EB"/>
        <circle cx="27" cy="14" r="2" fill="#2563EB"/>
        <circle cx="27" cy="26" r="2" fill="#2563EB"/>
        <circle cx="20" cy="20" r="2" fill="#7C3AED"/>
      </svg>
      <div className="flex flex-col leading-none">
        <span className="text-xl tracking-tight font-semibold">Nexus Learn</span>
        <span className="text-xs text-gray-600">AI Tutoring Platform</span>
      </div>
    </div>
  );
}

